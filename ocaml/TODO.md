- [ ] Spec requirements integration test coverage
    - [ ] Add log function
        - [ ] Output begins with ' [log] '
        - [ ] Only prints if DEBUG is set
    - [ ] Add interactive pkg tests (INS v0 B2.5)
        - [ ] Get su command from $XDG_CONFIG_HOME/tori/tori.conf
            - [ ] Default to 'su -c'
            - [ ] Validation
                - [ ] Valid path or in $PATH
                - [ ] Executability
                - [ ] 'true' exits with status 0
        - [ ] Add logging
            - [ ] Print each command executed, not just package names
        - [ ] Case with no packages provided
            - [ ] Prints a message
            - [ ] MUST NOT run any system commands
    - [x] Unrecognized command: exit code 1
    - [x] Command 'user': print the output of 'whoami'

- [ ] Refactorings
    - [ ] Simplify and analyze System.File
    - [ ] Simplify Reader

- [ ] Additionals
    - [ ] Create interface files
    - [ ] Expand unit tests coverage
    - [ ] Try out doc generation

## Notes

- INS = Iganaq Napkin Spec: <https://brew.bsd.cafe/tori/iganaq#specification>
- Spec v0 requirement B2.5 "MUST NOT run any system commands" is only testable
  if we wrap command execution properly in e.g. a list containing all executed
  commands and ensure no command is ever executed without being appended to it
