let merge (schema : Schema.schema) (packages : string list) : Schema.schema =
    match packages with
    | [] ->
        {
          schema with
          output = { schema.output with main = "No packages provided" };
        }
    | _ ->
        let su_command = schema.input.configuration.main.su_command in
        let commands : Process.Command.command list =
            [
              {
                name = su_command;
                arguments = [ su_command; "apk"; "-i"; "add" ] @ packages;
                status = Unevaluated;
              };
              {
                name = su_command;
                arguments = [ su_command; "apk"; "-i"; "del" ] @ packages;
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
