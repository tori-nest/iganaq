let read_channel channel =
    let buffer = Buffer.create 4096 in
    let rec read () =
        let line = input_line channel in
        Buffer.add_string buffer line;
        Buffer.add_char buffer '\n';
        read ()
    in
    try read () with End_of_file -> Buffer.contents buffer

let read path =
    let channel = open_in path in
    read_channel channel
