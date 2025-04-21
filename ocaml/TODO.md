- [ ] Spec requirements integration test coverage
    - [x] Add log function
        - [x] Output begins with ` [log] `
        - [x] Only prints if `DEBUG` is set
    - [ ] Add interactive pkg tests (INS v0 B2.5)
        - [ ] Get su command from `$XDG_CONFIG_HOME/tori/tori.conf`
            - [ ] Default to `su -c`
            - [ ] Validation
                - [ ] Valid path or in `PATH`
                - [ ] Executability
                - [-] `true` exits with status 0 (see note 3)
        - [x] Add logging
            - [x] Print each command executed, not just package names
        - [x] Case with no packages provided
            - [x] Prints a message
            - [x] MUST NOT run any system commands
    - [x] Unrecognized command: exit code 1
    - [x] Command `user`: print the output of `whoami`

- [ ] Refactorings
    - [ ] Simplify and analyze `System.File`
    - [ ] Simplify Reader

- [ ] Additionals
    - [ ] Create interface files
    - [ ] Expand unit tests coverage
    - [ ] Try out doc generation

## Notes

 1. INS = Iganaq Napkin Spec: <https://brew.bsd.cafe/tori/iganaq#specification>
 2. INS v0 B2.5 "MUST NOT run any system commands" is only testable if we wrap
    command execution properly in e.g. a list containing all executed commands
    and ensure no command is ever executed without being appended to it
 3. INS v0 A3.4 "running 'true' with exit code 0" requires the user to input
    their password every time. This should be dropped from the spec instead
