open Utilities.Aliases

let read_channel channel =
    let buffer = Buffer.create 4096 in
    let rec read () =
        let line = input_line channel in
        Buffer.add_string buffer line;
        Buffer.add_char buffer '\n';
        read ()
    in
    try read () with End_of_file -> Buffer.contents buffer

let can_read (path: string): bool =
    try Unix.access path [Unix.R_OK]; true
    with Unix.Unix_error _ ->
        elog $ "Failed to read file " ^ path;
        false

let read path =
    let channel = open_in path in
    read_channel channel
