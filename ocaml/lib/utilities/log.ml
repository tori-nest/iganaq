type context = Default | OS | Parsing

let elog ?(context: context option) (message : string) : unit =

    let debug_flag = try Unix.getenv "DEBUG" with Not_found -> "" in
    let log () = prerr_endline @@ " [log] " ^ message in

    match context with
    | None | Some Default -> if debug_flag <> "" then log ()
    | Some Parsing -> if debug_flag = "parsing" then log ()
    | Some OS -> if debug_flag = "os" then log ()
