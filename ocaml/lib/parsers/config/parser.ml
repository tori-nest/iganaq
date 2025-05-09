(* open Utilities.Aliases *)
open Lexer
open Utilities.Aliases

let default_config: Schema.main = Schema.origin.input.configuration.main

(*
    TODO: The `elog` calls in this module's functions cause cram tests
    to fail. Separate logging levels can be implemented to solve this.
*)

let parse_boolean (key: key) (value: string): Schema.default_bool =
    match value with
    | "true" -> true
    | "false" -> false
    | _ -> raise $ Malformed_source
        (Schema.string_of_key key ^ " must be either true or false")

let update_and_log ?message config key (value: string) : Schema.main =
    let message = match message with
        | Some s -> " (" ^ s  ^ ")"
        | None -> ""
    in
    elog $ "[c.parser.update] " ^ Schema.string_of_key key ^ " <- " ^ value ^ message;
    config

let update (past_config: Schema.main) key (value: string): Schema.main =
    let default = Schema.origin.input.configuration.main in
    match key with
    | Schema.SuCommand ->
        let default = Schema.origin.input.configuration.main in
        let as_list = String.split_on_char ' ' value in
        (* user set su_command, but not if it's quoted -> default to unquoted *)

        elog $ "value -> '" ^ value ^ "' <> '" ^
            String.concat " " default.su_command ^ "' <- default";
        elog $ "past_config.su_command_quoted -> '" ^
            str_dbool past_config.su_command_quoted ^ "' == '" ^
            str_dbool default.su_command_quoted ^ "' <- default";

        if value <> String.concat " " default.su_command &&
            past_config.su_command_quoted == default.su_command_quoted
        then
            update_and_log {
                past_config with su_command = as_list;
                su_command_quoted = false
            } key value ~message:("Defaulting to unquoted: set su_command_quoted to true if your su command needs quoting"
                )
        else
            update_and_log { past_config with su_command = as_list } key value ~message:("both su_command and su_command_quoted set by user")


    | SuCommandQuoted -> (
        if past_config.su_command == default.su_command then
            update_and_log { past_config with su_command_quoted = true }
                key "true" ~message: ("configuration value ignored: " ^
                "su_command is the default and 'su' requires quoting")
        else
            let parsed_boolean = parse_boolean key value in
            update_and_log
                { past_config with su_command_quoted = parsed_boolean }
                key (str_dbool parsed_boolean))
    | Unknown ->
        update_and_log past_config key value

let parse tokens: Schema.main =
    let rec parse_tokens tokens config ready_key =
        match tokens with
        | [] -> config
        | Key key :: tail ->
            elog $ "[c.parser.parse ] Picked key '" ^
                Schema.string_of_key key ^ "'";
            parse_tokens tail config (Some key)
        | Value value :: tail ->
            elog $ "[c.parser.parse ] Picked value '" ^ value ^ "'";
            (match ready_key with
                | Some key -> parse_tokens tail (update config key value) None
                | None -> raise $ Malformed_source "Value lacks preceding key")
        | Unknown char :: tail ->
            elog $ "[c.parser.parse ] Dropping unknown token " ^ str_char char;
            parse_tokens tail config ready_key
        | (Space|Equal|LineBreak|End) :: tail ->
            parse_tokens tail config ready_key

    in
    parse_tokens tokens default_config None

let apply (origin: Schema.schema) (config: Schema.main): Schema.schema =
    { origin with input = {
        origin.input with configuration = {
            origin.input.configuration with main = config
        }
    }}

let string_of_config (config: Schema.main): string =
    (* TODO: extract, use pattern matching for exhaustion checks *)
    "su_command = " ^ String.concat " " config.su_command ^ "\n" ^
    "su_command_quoted = " ^ str_dbool config.su_command_quoted
