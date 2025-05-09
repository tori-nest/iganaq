open Utilities.Aliases

type version = { major : int; minor : int; patch : int }
type help = { short : string; long : string }
type meta = { version : version; help : help; status : int }

type output = { main : string; log : string }

type os = Unknown | FreeBSD | Void | Alpine
type host = { os : os; name : string }

type configuration_key = SuCommand | Unknown
type main = { su_command : string; }
type configuration = { main : main; }
type input = { configuration: configuration; }

type schema = { meta : meta; output : output; input : input; host : host }

let origin : schema = {
    meta = {
        version = {
            major = 0;
            minor = 8;
            patch = 0;
        };
        help = {
            short = "<short help>";
            long = "<long help>";
        };
        status = 0;
    };
    input = {
        configuration = {
            main = {
                su_command = "su -c"
            };
        };
    };
    output = {
        (* could be lists of strings or lists of a dedicated type with message,
           log level, time and origin in code (e.g. module and function) *)
        main = "";
        log = "";
    };
    host = {
        os = Unknown;
        name = "Unknown Host";
    };
}

let format_version (version : version) : string =
    "v" ^ str_int version.major ^
    "." ^ str_int version.minor ^
    "." ^ str_int version.patch

let string_of_key key =
    match key with
        | SuCommand -> "su_command"
        | Unknown -> "<unknown key>"
