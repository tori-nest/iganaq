let interpret (past: Schema.schema) (input: string list): Schema.schema =

    let future = { past with output = { message = "" } } in

    (* say is useful when the only change to future is the output message *)
    let say (message: string) =
        { future with output = { message = message } } in

    (*
       TODO: return a schema with orders, instead of calling side-effects
       directly, making this more of a parser and less of a glorified switch
    *)
    match input with
    | "pkg" :: tail -> System.Package.merge past tail
    | "os" :: _ -> say (System.File.read "/etc/os-release")
    | "host" :: _ -> say (System.Process.Reader.read [||] "hostname").output
    | "echo" :: tail -> say (String.concat " " tail)
    | ("version" | "-v" | "--version") :: _ ->
        say (Schema.format_version future.meta.version)
    | ("help" | "-h" | "--help") :: _ -> say future.meta.help.long
    | head :: _ ->
        say ("Unrecognized command: " ^ head ^ "\n" ^ future.meta.help.short)
    | _ -> future
