open Lexer
open Utilities.Aliases

let default_config: Schema.main = Schema.origin.input.configuration.main

let parse_boolean (key: key) (value: string): Schema.default_bool =
    match value with
    | "true" -> true
    | "false" -> false
    | _ -> raise $ Malformed_source
        (Schema.string_of_key key ^ " must be either true or false")

let check (config: Schema.main): Schema.main =

    let default = Schema.origin.input.configuration.main in

    (* Ignore su_command_quoted value if su_command is the default,
       and default to unquoted if a custom su_command is set *)
    match config.su_command_quoted, config.su_command with
    | (true|false), su_command when su_command == default.su_command ->
        elog ~context:Parsing $ "[c.parser.check] " ^
        "Ignoring configuration key su_command_quoted: su_command is unset," ^
        " and the default su_command needs quoting";
        { config with su_command_quoted = default.su_command_quoted }
    | (true|false), _ -> config
    | Default, su_command when su_command <> default.su_command ->
        elog ~context:Parsing $ "[c.parser.check] " ^
        "Setting su_command_quoted to false: su_command is set, but " ^
        "su_command_quoted isn't. If it needs quoting, please set it to true";
        { config with su_command_quoted = false }
    | Default, _ -> config

let update (config: Schema.main) (key: Lexer.key) (value: string): Schema.main =
    elog ~context:Parsing $ "[c.parser.update] Matching value '" ^ value ^ "'";
    match key with
    | SuCommand -> { config with su_command = String.split_on_char ' ' value }
    | SuCommandQuoted -> { config with su_command_quoted = parse_boolean key value }
    | Interactive -> { config with interactive = bool_of_string value }
    | Simulate -> { config with simulate = bool_of_string value }
    | Unknown -> elog ~context:Parsing $ "[c.parser.update] Dropped value: unknown key"; config

let parse tokens: Schema.main =
    let rec parse_tokens tokens config ready_key =
        match tokens with
        | [] -> config
        | Key key :: tail ->
            elog ~context:Parsing $ "[c.parser.parse] Picked key '" ^
                Schema.string_of_key key ^ "'";
            parse_tokens tail config (Some key)
        | Value value :: tail ->
            elog ~context:Parsing $
            "[c.parser.parse] Picked value '" ^ value ^ "'";
            (match ready_key with
                | Some key -> parse_tokens tail (update config key value) None
                | None -> raise $ Malformed_source "Value lacks preceding key")
        | Unknown char :: tail ->
            elog ~context:Parsing $
            "[c.parser.parse] Dropping unknown token " ^ str_char char;
            parse_tokens tail config ready_key
        | (Space|Equal|LineBreak|End) :: tail ->
            parse_tokens tail config ready_key

    in
    parse_tokens tokens default_config None
    |> check

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
