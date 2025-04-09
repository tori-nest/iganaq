let () =
    match Array.to_list Sys.argv with
    | _ :: tail ->
        let future = (Tori.Parsers.Argument.interpret Tori.Schema.seed tail) in
        if future.output.message <> "" then print_endline future.output.message
    | [] -> assert false
