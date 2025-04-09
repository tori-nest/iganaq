- [ ] Match test coverage with spec requirements
- [ ] Add log function
    - [ ] Output begins with ' [log] '
    - [ ] Only prints if DEBUG is set
- [ ] Get su command from $XDG_CONFIG_HOME/tori/tori.conf and use it for pkg
    - [ ] Default to 'su -c'
    - [ ] Valid path or in $PATH, executability, 'true' exits with status 0
- [ ] Unrecognized command: exit code 1
- [ ] Package.merge should print each command executed, not just package names

- [ ] Simplify Reader
- [ ] Create interface files
    - [ ] Move comment on top of Parsers.Argument.say to the interface doc file
- [ ] Try out doc generation
- [ ] Simplify and analyze System.File

- [x] Command 'user': print the output of 'whoami'
- [x] Command 'host': drop
