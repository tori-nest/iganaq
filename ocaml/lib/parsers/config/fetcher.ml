let fetch ?clean (origin: Schema.schema): Schema.schema =
    let config = Lexer.read origin.meta.defaults.paths.configuration
    |> Lexer.scan
    |> List.concat
    |> Parser.parse
    in

    if Option.value clean ~default:false then {
        Schema.origin with input = {
            origin.input with configuration = {
                origin.input.configuration with main = config
            }
        }
    } else Parser.apply origin config
