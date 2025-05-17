open Utilities.Aliases

type install = { interactive: string list; batch: string list }
type manager = { install: install }
type manager_table = { apk: manager }

let table: manager_table = {
    apk = {
        install = {
            interactive = [ "apk"; "-i"; "add"; ];
            batch = [ "apk"; "--no-interactive"; "add"; ];
        }
    }
}

let su = Process.Su.elevate_wrapped
let manager = table.apk

let merge (schema : Schema.schema) (packages : string list) : Schema.schema =
    match packages with
    | [] ->
        {
          schema with
          output = { schema.output with main = "No packages provided" };
        }
    | _ ->
        let su_command_line = schema.input.configuration.main.su_command in
        let su_command = Process.Su.head_of_su_command su_command_line in
        let commands : Process.Command.command list =
            [
              {
                name = su_command;
                arguments = su schema $ manager.install.interactive @ packages;
                status = Unevaluated;
              };
              {
                name = su_command;
                arguments = su schema $ manager.install.interactive @ packages;
                status = Unevaluated;
              };
            ]
        in

        let ran = Process.Fork.run_many commands in
        let formatted_ran = Process.Command.format_many ran in

        {
          schema with
          output =
            {
              schema.output with
              log = "Done:\n" ^ String.concat "\n" formatted_ran;
            };
        }
