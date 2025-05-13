open Utilities.Aliases
type schema = Schema.schema

module type Monad = sig
    type 'f t
    val lift : 'f -> ('f * string)
    val (>>=) : 'f t -> ('f -> 'b t) -> 'b t
    val ( let* ) : 'f t -> ('f -> 'b t) -> 'b t
end

module type Writer = sig
    include Monad
    val write : string -> unit t
    val read : 'f t -> string
    val withdraw : 'f t -> 'f
end

module Writer : Writer with type 'f t = 'f * string = struct

    type 'f t = 'f * string

    let lift f = (f, "")

    let append_newline s =
        if s == "" then s else s ^"\n"

    let (>>=) pair f =
        let (past, pre_str) = pair in
        let (future, post_str) = f past in
        (future, append_newline pre_str ^ post_str)

    let ( let* ) = ( >>= )

    let write (s : string) = ((), s)
    let read (_, s) = s
    let withdraw (m, s) = print s; m (* should this I/O live here? *)

end

let demo : unit =
    let open Writer in

    let add (i: int) (m: schema): schema =
        { m with meta = { m.meta with status = m.meta.status + i }}
    in

    let log_add (i: int) (m: schema): schema t =
        let current = str_int m.meta.status in
        let partial = str_int $ m.meta.status + i in
        let addend = str_int i in
        add i m, "adding: " ^ current ^ " + " ^ addend ^ " = " ^ partial
    in

    let (m: schema) = withdraw (
        lift Schema.origin >>=
        log_add 1 >>=
        log_add 2 >>=
        (* how can this be simplified? *)
        fun carry -> write "just write" >>= fun () ->
        log_add 1 carry >>=
        log_add 5
    ) in

    print_endline $ "total: " ^ str_int m.meta.status

