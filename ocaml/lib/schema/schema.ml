type version = { major : int; minor : int; patch : int }
type help = { short : string; long : string }
type error_level = Clear | Warning | Error | Fatal
type paths = { configuration : string }
type defaults = { paths: paths }
type meta = {
    version : version;
    help : help;
    error_level: error_level;
    status : int;
    defaults : defaults;
}

type output = { main : string; log : string }

type os = Unknown | FreeBSD | Void | Alpine
type host = { os : os; name : string }

type default_bool = Default | true | false
type configuration_key = SuCommand | SuCommandQuoted | Unknown
type main = { su_command : string list; su_command_quoted: default_bool }
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
        error_level = Clear;
        status = 0;
        defaults = {
            paths = {
                configuration = Unix.getenv "HOME" ^ "/.config/tori/tori.conf";
            };
        };
    };
    input = {
        configuration = {
            main = {
                su_command = [ "su"; "-c" ];
                su_command_quoted = Default;
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
    "v" ^ string_of_int version.major ^
    "." ^ string_of_int version.minor ^
    "." ^ string_of_int version.patch

let string_of_key key =
    match key with
        | SuCommand -> "su_command"
        | SuCommandQuoted -> "su_command_quoted"
        | Unknown -> "<unknown key>"

let string_of_default_bool (b: default_bool) =
    match b with
    | true -> "true"
    | false -> "false"
    | Default -> "default"
