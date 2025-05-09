val parse : Lexer.token list -> Schema.main
val apply : Schema.schema -> Schema.main -> Schema.schema
val string_of_config : Schema.main -> string
