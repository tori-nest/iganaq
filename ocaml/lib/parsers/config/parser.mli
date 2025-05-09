type token = Lexer.token
type schema = Schema.schema
type config = Schema.main

val parse : token list -> config
val apply : schema -> config -> schema
val string_of_config : config -> string
