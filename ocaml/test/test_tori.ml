module Reader = Tori.System.Process.Reader
module File = Tori.System.File

let smoke () =
    (* Executing echo should return the same string on output *)
    let result = Reader.read [||] "echo 0x70121" in
    assert (Reader.format result = "0x70121");

    (* Reading a file, relying on Dune's directory structure *)
    let file_contents = File.read "../tori.opam" in
    let contents_list = String.split_on_char '\n' file_contents in
    assert (List.mem "depends: [" contents_list)

let () = smoke ()
