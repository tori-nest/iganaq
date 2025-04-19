let run (command : Command.command) : Command.command =
    match Unix.fork () with
    | 0 -> Unix.execvp command.name (Array.of_list command.arguments)
    | pid -> (
        let _, status = Unix.waitpid [] pid in
        match status with
        | WSTOPPED n | WSIGNALED n | WEXITED n ->
            { command with status = Exit n }
      )

let run_many (commands : Command.command list) : Command.command list =
    List.map run commands
