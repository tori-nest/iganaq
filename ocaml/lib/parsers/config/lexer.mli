type key = Schema.configuration_key

type token =
    | Key of key
    | Equal
    | Value of string
    | Space
    | LineBreak
    | Unknown of char
    | End

val read : string -> char list list
val scan : char list list -> token list list
val string_of_tokens : token list list -> string

exception Malformed_source of string
