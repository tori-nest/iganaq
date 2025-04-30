open Utilities.Aliases
(*
    1. read file at $XDG_CONFIG_DIR/tori/tori.conf
    2. Parse the line 'su_command = doas' and:
        2.1. if this line is not found, su_command MUST default to 'su -c'
        2.2. if it is found, the su_command used MUST be whatever was specified
    5. Whatever su_command MUST be validated for:
        5.1. presence at the path provided or obtained from $PATH
        5.2. executability
*)
type key = SuCommand | Unknown
type token =
    | Key of key
    | Equal
    | Value of string
    | Space
    | LineBreak
    | Unknown of char
    | End

let lex_keyword (chars: char list) (next_index: int): token * int =
    let stop = match List.find_index ((==) '=') chars with
        | Some i -> i
        | None -> assert false (* TODO: Exception 'line has no equals sign' *)
    in
    let literal = String.trim @@ str_chars (List.filteri (fun i _ -> i >= 0 && i < stop) chars) in
    match literal with
    | "su_command" -> Key SuCommand, next_index
    | _ -> Key Unknown, next_index

let lex_keyvalue (chars: char list): token * int =
    let length = List.length chars in
    let start = match List.find_index ((==) '=') chars with
        | Some i -> i
        | None -> assert false (* TODO: Exception 'line has no equals sign' *)
    in
    let literal = String.trim @@ str_chars
        (List.filteri (fun i _ -> i >= start + 1 && i < length - 1) chars) in
    Value literal, length - 1

let lex_keypair (chars: char list) (index: int): token * int =

    let boundary =
        match List.find_index ((==) '=') chars with
        | Some b -> b - 1
        | None -> assert false (* TODO: Exception 'line has no equals sign' *)
    in
    let next_index = if index < boundary then boundary else index + 1 in
    let literal = str_chars (List.filteri (fun i _ -> i >= index && i < next_index) chars) in
    elog @@ "[lex_keypair] Index " ^ str_int index ^
        ": Found literal '" ^ literal ^
        "', boundary " ^ (str_int boundary) ^
        " next index " ^ (str_int next_index);

    if index < boundary then
        lex_keyword chars next_index
    else
        lex_keyvalue chars

let lex (chars: char list) (index: int): token * int =
    elog @@ "[lex] Index " ^ (str_int index);
    match List.nth chars index with
    | '=' -> Equal, index + 1
    | ' '|'\t' -> Space, index + 1
    | '\n' -> LineBreak, index + 1
    | 'a'..'z'|'~'|'/' -> lex_keypair chars index
    | c -> Unknown c, index + 1

let read (path: string): char list list =
    let contents = (System.File.read path) in
    let lines = String.split_on_char '\n' contents in
    let lines = List.mapi (fun i s -> if i+1 < List.length lines then s ^ "\n" else s) lines in
    let rec split (strings: string list) (index: int) (char_lists: char list list) =
        if index == List.length strings then char_lists
        else split strings (index + 1)
            (chars_str (List.nth strings index) :: char_lists)
    in
    List.rev (split lines 0 [])

let scan_line (input: char list): token list =
    elog @@ "[scan_line] At " ^ (String.trim @@ str_chars input);
    let rec traverse (chars: char list) (index: int) (tokens: token list) =
        if index == List.length chars then tokens
        else let token, next_index = lex chars index in
            traverse chars next_index (token :: tokens)
    in List.rev (traverse input 0 [])

let scan (char_lists: char list list): token list list =
    let rec scan' (char_lists': char list list) (index: int) (token_lists: token list list) =
        if index == List.length char_lists' then [End] :: token_lists
        else scan' char_lists' (index + 1) (scan_line (List.nth char_lists' index) :: token_lists)
    in
    List.rev (scan' char_lists 0 [])

let string_of_tokens (tokens: token list list): string =
    let extract (token: token): string =
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
    let rec assemble (tokens: token list) index (output: string) =
        if index == List.length tokens then output
        else assemble tokens (index + 1) (output ^ " " ^ extract (List.nth tokens index))
    in
    let rec traverse (token_lists: token list list) index output: string =
        if index == List.length token_lists then output
        else traverse token_lists (index + 1)
            (assemble (List.nth token_lists index) 0 output)
    in
    traverse tokens 0 " { Start of File }\n"

