let chars_of_string (string: string): char list =
    let rec split string index chars =
        if index = String.length string then chars
        else split string (index + 1) (string.[index] :: chars)
    in List.rev (split string 0 [])

let string_of_chars (chars: char list): string =
    String.concat "" (List.map (String.make 1) chars)
