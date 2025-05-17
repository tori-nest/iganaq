let interpret (past : Schema.schema) (arguments : string list) : Schema.schema =

    let say (message : string) : Schema.schema =
        { past with output = { past.output with main = message } }
    in

    (*
       TODO: return a schema with orders, instead of calling side-effects
       directly, making this more of a parser and less of a glorified switch
    *)
    match arguments with
    | "pkg" :: tail -> System.Package.merge past tail
    | "os" :: _ -> say System.Os.identify
    | "user" :: _ -> say (System.Process.Reader.read [||] "whoami").output
    | "echo" :: tail -> say (String.concat " " tail)
    | ("version" | "-v" | "--version") :: _ ->
        say (Schema.format_version past.meta.version)
    | ("help" | "-h" | "--help") :: _ -> say past.meta.help.long
    | head :: _ ->
        {
          past with
          output =
            {
              past.output with
              main =
                "Unrecognized command: " ^ head ^ "\n" ^ past.meta.help.short;
            };
          meta = { past.meta with status = 1 };
        }
    | _ -> past
