open Utilities.Aliases

type output = { output : string; error : string; status : string }

let handle_exit_status (status : Unix.process_status) : string =
    match status with
    | Unix.WEXITED n -> "Exit " ^ str_int n
    | Unix.WSIGNALED n -> "Kill " ^ str_int n
    | Unix.WSTOPPED n -> "Stopped " ^ str_int n

let read (env : string array) (command : string) : output =
    let stdout, stdin, stderr = Unix.open_process_full command env in
    let in_buffer = Buffer.create 4096 in
    let err_buffer = Buffer.create 4096 in

    let rec read_in () =
        let in_line = input_line stdout in
        Buffer.add_string in_buffer in_line;
        Buffer.add_char in_buffer '\n';
        read_in ()
    in
    try read_in ()
    with End_of_file -> (
      ();

      let rec read_err () =
          let err_line = input_line stderr in
          Buffer.add_string err_buffer err_line;
          Buffer.add_char err_buffer '\n';
          read_err ()
      in
      try read_err ()
      with End_of_file ->
        let exit_status =
            handle_exit_status (Unix.close_process_full (stdout, stdin, stderr))
        in
        {
          output = String.trim (Buffer.contents in_buffer);
          error = Buffer.contents err_buffer;
          status = exit_status;
        }
    )

let format (output : output) : string =
    match output with
    | { output = o; error = _; status = "Exit 0" } -> o
    | { output = ""; error = e; status = s } -> "[" ^ s ^ "]" ^ " " ^ e
    | { output = o; error = _; status = s } -> "[" ^ s ^ "]" ^ " " ^ o
