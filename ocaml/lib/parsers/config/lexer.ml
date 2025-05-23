open Utilities.Aliases

type key = Schema.configuration_key
type token =
    | Key of key
    | Equal
    | Value of string
    | Space
    | LineBreak
    | Unknown of char
    | End

    (*
        TODO: This module's functions rely too much on matching a string, so
        there are no exhaustion checks and it's entirely up to the human to
        not overlook a variant, possibly leading to unhandled cases. Either
        refactor, add tests that will fail if a variant is unhandled, or both
    *)

let lex_keyword (literal: string): token =
    match literal with
    | "su_command" -> Key SuCommand
    | "su_command_quoted" -> Key SuCommandQuoted
    | "interactive" -> Key Interactive
    | "simulate" -> Key Simulate
    | _ -> Key Unknown

let lex_keyvalue (literal: string): token = Value literal

let string_of_token (token: token): string =
    match token with
    | Key k -> (match k with
        | SuCommand -> "[ KEY: su_command ]"
        | SuCommandQuoted -> "[ KEY: su_command_quoted ]"
        | Interactive -> " [ KEY: interactive ]"
        | Simulate -> " [ KEY: simulate ]"
        | Unknown -> "[ UNKNOWN KEY ]")
    | Equal -> "[ OP: equal ]"
    | Value v -> "[ VAL: " ^ v ^ " ]"
    | Space -> "{ Space }"
    | LineBreak -> "{ LineBreak }\n"
    | End -> "{ End of File }\n"
    | Unknown s -> (String.make 1 s)

let string_of_tokens (tokens: token lists): string =
    String.concat " " $ map string_of_token (List.concat tokens)

let lex_keypair (chars: char list) (position: int): token * int =

    (* For a keypair abc = bcd\n, the middle position is the first space
       before =, or = itself if there are no spaces. The final position is the
       middle position if parsing before it, or the newline \n if past it *)

    let middle_position =
        match List.find_index (fun c -> c == '=' || c == ' ') chars with
        | Some b -> b
        | None -> raise $ Malformed_source
            ("No equal operator for position " ^ str_int position)
    in
    let final_position =
        if position < middle_position then middle_position
        else (length chars) - 1 in
    let literal = str_chars
        (ifilter (fun i _ -> i >= position && i < final_position) chars) in

    if position < middle_position then
        lex_keyword literal, final_position
    else
        lex_keyvalue literal, final_position

let lex (chars: char list) (position: int): token * int =
    match pick position chars with
        | '=' -> Equal, position + 1
        | ' '|'\t' -> Space, position + 1
        | '\n' -> LineBreak, position + 1
        | 'a'..'z'|'~'|'/' -> lex_keypair chars position
        | c -> Unknown c, position + 1

let read (path: string): char lists =
    if not $ System.File.can_read path then [[]] else
    let lines = System.File.read path
    |> String.split_on_char '\n'
    |> List.map String.trim in
    let lines = imap
        (fun i s -> if i + 1 < length lines then s ^ "\n" else s) lines in
        (* adds a newline to each line end, except the last *)
    let rec to_char_lists
        (strings: string list) (position: int) (char_lists: char lists) =
        if position == length strings then char_lists
        else to_char_lists strings (position + 1)
            char_lists $: chars_str (pick position strings)
    in
    to_char_lists lines 0 []

let scan_line (input: char list): token list =
    let rec to_tokens (chars: char list) (position: int) (tokens: token list) =
        if position == length chars then tokens
        else let token, next_position = lex chars position in
            to_tokens chars next_position $ token :: tokens
    in
    reverse $ to_tokens input 0 []

let scan (char_lists: char lists): token lists =
    let tokens = rmap (scan_line) char_lists $: [End] in
    elog ~context:Parsing $ string_of_tokens tokens;
    tokens
