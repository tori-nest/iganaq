# iganaq OCaml

This is the OCaml implementation of the iganaq prototype. See the [root README](../README.md) for the general description.

## Configuration parser

Grammar v0.2:

    assignment  = { space }, key, { space }, equal, [ space ], value
    key         = letter, { letter | digit | "_" }, equal
    value       = valuable, { " " | valuable }, break
    valuable    = ( letter | digit | "_" | "-" | "~" | "/" ), { valuable }
    equal       = "="
    break       = "\n"
    space       = " " | "\t"

Written using the ISO 14977 EBNF Notation.

In this grammar, `digit` implies `decimal digit`. Spaces between the key and the `=` operator are lexed but meaningless. The first space after the `=` operator is parsed but meaningless. Additional spaces between the first space after the `=` operator and the first non-space character of the value are lexed and considered as part of the value. Spaces before the key and after the last non-space character until the newline are not lexed.

- ~Note: non-terminals `key` and `value` are ambiguous~.
    - Resolved by specifying what character terminates each

## Task list

- [ ] Spec requirements
    - [x] Add log function
        - [x] Output begins with ` [log] `
        - [x] Only prints if `DEBUG` is set
    - [ ] Add interactive pkg tests (INS[^1] v0 B2.5[^2])
    - [x] Get su command from `$XDG_CONFIG_HOME/tori/tori.conf`
        - [ ] Default to `su -c`
            - [ ] Handle fatal `Sys_error` if `tori.conf` doesn't exist
            - [ ] Handle checking `su -c` default with `which` when `tori.conf` exists but `su_command` is absent in it
            - [ ] Properly handle a compose `su_command` such as `su -c` in `System.Package`
        - [x] Validation
            - [x] Valid path or in `PATH`
            - [x] Executability
            - ~`true` exits with status 0~[^3]
    - [x] Add logging
        - [x] Logs only if DEBUG is set
        - [x] Print each command executed, not just package names
    - [x] Case with no packages provided
        - [x] Prints a message
        - [x] MUST NOT run any system commands
    - [x] Unrecognized command: exit code 1
    - [x] Command `user`: print the output of `whoami`
    - [x] Command `os`: print the OS name
        - [x] log the contents of `/etc/os-release`[^4]

- [ ] Incrementals
    - [ ] Simplify and analyze `System.File`
    - [ ] Simplify Reader

- [ ] Additionals
    - [ ] Create remaining interface files
    - [ ] Expand unit tests coverage
    - [ ] Try out doc generation

- [ ] Check out
    - [ ] <https://github.com/janestreet/shexp>
    - [ ] <https://erratique.ch/software/bos>
    - [ ] <https://github.com/ninjaaron/ocaml-subprocess>
    - [ ] <https://github.com/charlesetc/feather>

## References

- ISO 14977 EBNF Notation: <https://www.cl.cam.ac.uk/~mgk25/iso-14977.pdf>
- Comparison of BNF notations: <https://www.cs.man.ac.uk/~pjj/bnf/ebnf.html>
- W3C ABNF Notation: <https://www.w3.org/Notation.html>
- IETF RFC 5234 ABNF Notation (replaces 4234, 2234): <https://www.rfc-editor.org/rfc/rfc5234>

### Notes

[^1]: INS, Iganaq Napkin Spec: <https://brew.bsd.cafe/tori/iganaq#specification>
[^2]: INS v0 B2.5 "MUST NOT run any system commands" is only testable if we wrap command execution properly in e.g. a monad or list containing all executed commands, ensuring no command is ever executed without being appended to it
[^3]: INS v0 A3.4 "running 'true' with exit code 0" requires the user to input their password every time. This was dropped in INS v0.2, where "run 'true' with exit code 0" was removed from A3.4
[^4]: INS v0.1 changes requirement B2.3 to "MUST print the OS name and MUST log contents of /etc/os-release" in order to make the logging function testable without user input
