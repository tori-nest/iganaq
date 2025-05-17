open Utilities.Aliases

type command = { interactive: string list; batch: string list }
type manager = { install: command; remove: command }
type manager_table = { apk: manager }

let table: manager_table = {
    apk = {
        install = {
            interactive = [ "apk"; "-i"; "add"; ];
            batch = [ "apk"; "--no-interactive"; "add"; ];
        };
        remove = {
            interactive = [ "apk"; "-i"; "del"; ];
            batch = [ "apk"; "--no-interactive"; "del"; ];
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
                arguments = su schema $ manager.remove.interactive @ packages;
                status = Unevaluated;
              };
            ]
        in

        let simulate = schema.input.configuration.main.simulate in
        let log_output =
            if simulate then
                "Would execute:\n" ^
                String.concat "\n" (Process.Command.format_many commands)
            else
                let ran =
                    if simulate then [] else Process.Fork.run_many commands in
                "Executed:\n" ^
                String.concat "\n" (Process.Command.format_many ran) in

        {
          schema with
          output =
            {
              schema.output with
              log = log_output;
            };
        }
