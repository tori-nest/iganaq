open Qol

let run (command: string) (arguments: string list) =
    match Unix.fork () with
    | 0 -> Unix.execvp command (Array.of_list arguments)
    | pid -> let (_, status) = Unix.waitpid [] pid in
        match status with
        | Unix.WEXITED 0 -> ()
        | Unix.WEXITED n -> print ("Process exited with code " ^ str_int n)
        | Unix.WSIGNALED n -> print ("Process terminated by signal " ^ str_int n)
        | Unix.WSTOPPED n -> print ("Process stopped by signal " ^ str_int n)
