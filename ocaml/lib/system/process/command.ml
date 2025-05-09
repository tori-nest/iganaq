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
