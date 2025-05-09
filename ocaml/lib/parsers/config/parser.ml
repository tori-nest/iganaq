(* open Utilities.Aliases *)
open Lexer

type schema = Schema.schema
type token = Lexer.token
type config = Schema.main

let default_config: config = Schema.origin.input.configuration.main

(*
    TODO: The `elog` calls in this module's functions cause cram tests
    to fail. Separate logging levels can be implemented to solve this.
*)

let update config key value: config =
    match key with
    | Schema.SuCommand ->
        (* elog $ "[c.parser.update] Setting value '" ^ value ^ "'"; *)
        { config with Schema.su_command = value }
    | Unknown ->
        (* elog $ "[c.parser.update] Dropping value: unknown key"; *)
        config

let parse tokens =
    let rec parse_tokens tokens config ready_key =
        match tokens with
        | [] -> config
        | Key key :: tail ->
            (* elog $ "[c.parser.parse ] Picked key '" ^ *)
            (*     Schema.string_of_key key ^ "'"; *)
            parse_tokens tail config (Some key)
        | Value value :: tail ->
            (* elog $ "[c.parser.parse ] Picked value '" ^ value ^ "'"; *)
            (match ready_key with
                | Some key -> parse_tokens tail (update config key value) None
                | None -> raise (Malformed_source "Value lacks preceding key"))
        | Unknown _char :: tail ->
            (* elog $ "[c.parser.parse ] Dropping unknown token " ^ str_char char; *)
            parse_tokens tail config ready_key
        | (Space|Equal|LineBreak|End) :: tail ->
            parse_tokens tail config ready_key

    in
    parse_tokens tokens default_config None

let apply (origin: Schema.schema) (config: config): Schema.schema =
    { origin with input = {
        origin.input with configuration = {
            origin.input.configuration with main = config
        }
    }}

let string_of_config (config: config): string =
    "su_command = " ^ config.su_command ^ "\n" ^
    ""
