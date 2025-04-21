let elog (message : string) : unit =
    let debug_flag = try Unix.getenv "DEBUG" with Not_found -> "" in

    if debug_flag <> "" then prerr_endline @@ " [log] " ^ message
