open Qol

type version = { major: int; minor: int; patch: int }
type help = { short: string; long: string }
type meta = { version: version; help: help }

type output = { message: string; }

type os = Unknown | FreeBSD | Void | Alpine
type host = { os: os; name: string; }

type schema = { meta: meta; output: output; host: host; }

let seed: schema = {
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
    };
    output = {
        message = "";
    };
    host = {
        os = Unknown;
        name = "Unknown Host";
    };
}

let format_version (version: version): string =
    "v" ^ str_int version.major ^
    "." ^ str_int version.minor ^
    "." ^ str_int version.patch
