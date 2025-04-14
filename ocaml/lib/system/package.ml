let merge (schema: Schema.schema) (packages: string list): Schema.schema =

    match packages with
    | [] -> { schema with output = {
        schema.output with main = "No packages provided" }
    }
    | _ ->

        let commands: Process.Command.command list = [
            {
                name = "doas";
                arguments = ["doas"; "apk"; "-i"; "add"] @ packages;
                status = Unevaluated;
            };
            {
                name = "doas";
                arguments = ["doas"; "apk"; "-i"; "del"] @ packages;
                status = Unevaluated;
            }
        ] in

        let ran = Process.Fork.run_many commands in
        let formatted_ran = Process.Command.format_many ran in

        {
            schema with output = {
                schema.output with log =
                    "Done:\n" ^ (String.concat "\n" formatted_ran)
            }
        }
