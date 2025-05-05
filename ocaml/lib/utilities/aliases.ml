(* an 'alias' is an alternate name with minor or no alterations to behavior *)

(* logging *)
let print = print_endline
let elog = Log.elog

(* casts *)
let str_int = string_of_int
let chars_str = Text.chars_of_string
let str_chars = Text.string_of_chars

(* control flow & precedence *)
let ($) = (@@)

(* lists *)
type 'a lists = 'a list list
let ($:) list element = list @ [element]
let pick index list = List.nth list index
let rmap = List.rev_map
let reverse = List.rev
let length = List.length
let ifilter = List.filteri
let imap = List.mapi
let map = List.map
