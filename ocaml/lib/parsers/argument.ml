let interpret (past : Schema.schema) (input : string list) : Schema.schema =
    let future : Schema.schema =
        { past with output = { past.output with main = "" } }
    in

    let say (message : string) : Schema.schema =
        { future with output = { future.output with main = message } }
    in

    (*
       TODO: return a schema with orders, instead of calling side-effects
       directly, making this more of a parser and less of a glorified switch
    *)
    match input with
    | "pkg" :: tail -> System.Package.merge past tail
    | "os" :: _ -> say (System.File.read "/etc/os-release")
    | "user" :: _ -> say (System.Process.Reader.read [||] "whoami").output
    | "echo" :: tail -> say (String.concat " " tail)
    | ("version" | "-v" | "--version") :: _ ->
        say (Schema.format_version future.meta.version)
    | ("help" | "-h" | "--help") :: _ -> say future.meta.help.long
    | head :: _ ->
        {
          future with
          output =
            {
              future.output with
              main =
                "Unrecognized command: " ^ head ^ "\n" ^ future.meta.help.short;
            };
          meta = { future.meta with status = 1 };
        }
    | _ -> future
