let merge (schema: Schema.schema) (packages: string list) =

    match packages with
    | [] -> { schema with output = { message = "No packages provided" } }
    | _ ->

    let in_targets = List.flatten [["doas"; "apk"; "-i"; "add"]; packages] and
        out_targets = List.flatten [["doas"; "apk"; "-i"; "del"]; packages] in

        Process.Fork.run "doas" in_targets;
        Process.Fork.run "doas" out_targets;

        { schema with output = {
            message = "Done: " ^ (String.concat "\n" packages)
        }}
