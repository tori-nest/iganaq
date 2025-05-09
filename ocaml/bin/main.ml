module ConfigFetcher = Tori.Parsers.Config.Fetcher

let () =

    match Array.to_list Sys.argv with
    | _ :: tail ->
        let past = ConfigFetcher.fetch Tori.Schema.origin
            |> Tori.Checks.post_config
        in
        let future = Tori.Parsers.Argument.interpret past tail
            |> Tori.Checks.exit
        in
        exit future.meta.status
    | [] -> assert false
