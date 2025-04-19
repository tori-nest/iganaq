open Tori.Utilities.Aliases

let () =
    match Array.to_list Sys.argv with
    | _ :: tail ->
        let future = Tori.Parsers.Argument.interpret Tori.Schema.seed tail in
        if future.output.main <> "" then print_endline future.output.main;
        if future.output.log <> "" then elog future.output.log;
        exit future.meta.status
    | [] -> assert false
