open Utilities.Aliases

type key = SuCommand | Unknown
type token =
    | Key of key
    | Equal
    | Value of string
    | Space
    | LineBreak
    | Unknown of char
    | End

let lex_keyword (literal: string): token =
    match literal with
    | "su_command" -> Key SuCommand
    | _ -> Key Unknown

let lex_keyvalue (literal: string): token = Value literal

let is_boundary char = char == '=' || char == ' '

let lex_keypair (chars: char list) (position: int): token * int =

    let boundary =
        match List.find_index is_boundary chars with
        | Some b -> b
        | None -> assert false (* TODO: Exception 'line has no equals sign' *)
    in
    let next_position =
        if position < boundary then boundary
        else (List.length chars) - 1 in
    let literal = str_chars
        (List.filteri (fun i _ -> i >= position && i < next_position) chars) in

    elog @@ "[lex_keypair] Position " ^ str_int position ^
        ": Found literal '" ^ literal ^
        "', boundary " ^ (str_int boundary) ^
        " next position " ^ (str_int next_position);

    if position < boundary then
        lex_keyword literal, next_position
    else
        lex_keyvalue literal, List.length chars - 1

let lex (chars: char list) (position: int): token * int =
    elog @@ "[lex] Position " ^ (str_int position);
    match List.nth chars position with
    | '=' -> Equal, position + 1
    | ' '|'\t' -> Space, position + 1
    | '\n' -> LineBreak, position + 1
    | 'a'..'z'|'~'|'/' -> lex_keypair chars position
    | c -> Unknown c, position + 1

let read (path: string): char list list =
    let contents = (System.File.read path) in
    let lines = String.split_on_char '\n' contents in
    let lines = List.mapi
        (fun i s -> if i+1 < List.length lines then s ^ "\n" else s) lines in
    let rec split (strings: string list) position (char_lists: char list list) =
        if position == List.length strings then char_lists
        else split strings (position + 1)
            (chars_str (List.nth strings position) :: char_lists)
    in
    List.rev (split lines 0 [])

let scan_line (input: char list): token list =
    elog @@ "[scan_line] At " ^ (String.trim @@ str_chars input);
    let rec traverse (chars: char list) (position: int) (tokens: token list) =
        if position == List.length chars then tokens
        else let token, next_position = lex chars position in
            traverse chars next_position (token :: tokens)
    in List.rev (traverse input 0 [])

let scan (char_lists: char list list): token list list =
    let rec scan' (char_lists': char list list) (position: int) (token_lists: token list list) =
        if position == List.length char_lists' then [End] :: token_lists
        else scan' char_lists' (position + 1) (scan_line (List.nth char_lists' position) :: token_lists)
    in
    List.rev (scan' char_lists 0 [])

let string_of_tokens (tokens: token list list): string =
    let string_of_token (token: token): string =
        match token with
        | Key k -> (match k with
            | SuCommand -> "[ KEY: su_command ]"
            | Unknown -> "[ UNKNOWN KEY ]")
        | Equal -> "[ OP: equal ]"
        | Value v -> "[ VAL: " ^ v ^ " ]"
        | Space -> "{ Space }"
        | LineBreak -> "{ LineBreak }\n"
        | End -> "{ End of File }\n"
        | Unknown s -> (String.make 1 s)
    in
    let rec join_strings (tokens: token list) position (output: string): string =
        if position == List.length tokens then output
        else join_strings tokens (position + 1)
            (output ^ " " ^ string_of_token (List.nth tokens position))
    in
    join_strings (List.concat tokens) 0 ""

