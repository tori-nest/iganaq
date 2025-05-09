open Tori.Utilities.Aliases

module ConfigLexer = Tori.Parsers.Config.Lexer
module ConfigParser = Tori.Parsers.Config.Parser

let config_file =
    ConfigLexer.read $ Unix.getenv "HOME" ^ "/.config/tori/tori.conf"

let () =

    (* TODO: extract *)
    let tokens = ConfigLexer.scan config_file in
    (* elog $ ConfigLexer.string_of_tokens tokens; *)
    let config = ConfigParser.parse (List.concat tokens) in
    (* elog $ ConfigParser.string_of_config config; *)

    match Array.to_list Sys.argv with
    | _ :: tail ->
        let past = ConfigParser.apply Tori.Schema.origin config in
        let future = Tori.Parsers.Argument.interpret past tail in
        if future.output.main <> "" then print_endline future.output.main;
        if future.output.log <> "" then elog future.output.log;
        exit future.meta.status
    | [] -> assert false
