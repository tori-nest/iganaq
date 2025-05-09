open Utilities.Aliases

type schema = Schema.schema

type status = Exit of int | Unevaluated
type command = { name : string; arguments : string list; status : status }


let format (command : command) : string =
    command.name ^ " with arguments: "
    ^ String.concat " " command.arguments
    ^ " and result "
    ^
    match command.status with
    | Exit n -> str_int n
    | Unevaluated -> "Not evaluated"

let format_many (commands : command list) : string list =
    List.map format commands

let check_su_command (schema: schema): schema =
    let command = schema.input.configuration.main.su_command in
    let path = Reader.read [||] ("which " ^ command) in
    try Unix.access path.output [Unix.X_OK]; schema
    with Unix.Unix_error _ -> elog "";
        {
            schema with
            output =
                {
                    schema.output with
                    main =
                        "Super user command " ^ command ^
                        " not executable at path '" ^ path.output ^
                        "' (exit status " ^ path.status ^ ", stderr: '" ^
                        path.error ^ "')\n"
                };
            meta = { schema.meta with status = 1 };
        }
