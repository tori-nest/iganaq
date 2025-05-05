type token
val read : string -> char list list
val scan : char list list -> token list list
val string_of_tokens : token list list -> string
