(* the side effect could be extracted to a log list in the schema *)
let identify : string =
    let os_release = String.split_on_char '\n' (File.read "/etc/os-release") in
    Utilities.Log.elog (String.concat "\n" os_release);

    let os_equals = List.find (String.starts_with ~prefix:"NAME=") os_release in
    match String.split_on_char '=' os_equals with
    | [ _; s ] ->
        String.trim @@ String.map (fun c -> if c = '"' then ' ' else c) s
    | _ -> "Unknown"
