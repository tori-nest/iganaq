open Utilities.Aliases
type schema = Schema.schema

let head_of_su_command command_line =
    match command_line with
    | head :: _ -> head
    | [] -> raise $ Malformed_source "su_command is set to an empty value"

let elevate_wrapped (schema: schema) (command: string list): string list =
    let su_command = schema.input.configuration.main.su_command in
    match schema.input.configuration.main.su_command_quoted with
    | true|Default -> List.concat [ su_command; [(String.concat " " command)]; ]
    | false -> List.concat [ su_command; ["--"]; (command); ]

let is_executable (schema: schema): schema =
    let command = head_of_su_command
        schema.input.configuration.main.su_command in
    let path = Reader.read [||] ("which " ^ command) in
    try Unix.access path.output [Unix.X_OK]; schema
    with Unix.Unix_error _ -> elog "";
        {
            schema with
            output =
                {
                    schema.output with
                    main =
                        "The configured super user command " ^ command ^
                        " either could not be found at path '" ^ path.output ^
                        "' or you lack permissions to execute it ("
                        ^ path.status ^ ", stderr: '" ^ path.error ^ "')\n"
                };
            meta = { schema.meta with status = 1; error_level = Fatal };
        }

