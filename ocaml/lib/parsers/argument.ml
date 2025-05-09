let interpret (past : Schema.schema) (input : string list) : Schema.schema =
    let present : Schema.schema =
        { past with output = { past.output with main = "" } }
    in

    let say (message : string) : Schema.schema =
        { present with output = { present.output with main = message } }
    in

    let configured_present = System.Process.Command.check_su_command present in

    (* poor legibility, but otherwise flagged as non-exhaustive *)
    match configured_present.meta.status with
    | n when n <> 0 -> configured_present
    | _ ->

    (*
       TODO: return a schema with orders, instead of calling side-effects
       directly, making this more of a parser and less of a glorified switch
    *)
    match input with
    | "pkg" :: tail -> System.Package.merge past tail
    | "os" :: _ -> say System.Os.identify
    | "user" :: _ -> say (System.Process.Reader.read [||] "whoami").output
    | "echo" :: tail -> say (String.concat " " tail)
    | ("version" | "-v" | "--version") :: _ ->
        say (Schema.format_version present.meta.version)
    | ("help" | "-h" | "--help") :: _ -> say present.meta.help.long
    | head :: _ ->
        {
          present with
          output =
            {
              present.output with
              main =
                "Unknown command: " ^ head ^ "\n" ^ present.meta.help.short;
            };
          meta = { present.meta with status = 1 };
        }
    | _ -> present
