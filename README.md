# tori-iganaq

This is a sandbox project containing alternative implementations of [tori](https://tori.jutty.dev/) using different programming languages. Its name is a reference to a location in the migration routes of puffin birds, the tori symbol.

After evaluating how each solution measures up to the project requirements, the result should be a new main implementation to replace the current one.

The plan is to evaluate three candidate languages: **OCaml**, **Haskell** and **Rust**. They were chosen for their ability to compile to portable binaries and for their rich type systems that can support predictable and strict logic requirements. OCaml and Haskell, particularly, are interesting candidates for configuration parsing and execution of side-effects only in an outer layer of the architecture.

## Rationale

So far, tori has been implemented using POSIX shell scripts. The rationale for this choice has been explained in the [documentation](https://tori.jutty.dev/docs/development/portability.html) and leans heavily on the fact that, because mostly any unix system is bound to have a POSIX shell available, this means you can run (and modify) tori without any extra requirements, not even a C compiler or any libraries.

While this is a good advantage, what really tipped the scale was how _uncertain_ it felt when running tests in the form of shell scripts. It all depends on the underlying shell's `errexit` and `nounset` options, which can be unpredictable depending on the shell implementation and the context you are evaluating in (e.g. inside a function, inside a sub-shell, inside an if condition, ...).

As a program that can brick your system if something goes wrong, it's really important that tori is highly testable and predictable. And that is not something that can be reasonably done using shell scripting.

## Specification

Each language will be used to implement a simple command-line interface that fulfills the specification below. "Simple" means the goal is not to cover corner cases, but to prototype and make a decision based on language syntax, ergonomics, expressiveness, documentation, ecosystem, tooling and overall experience.

                               Iganaq Napkin Spec v0

      A1. 'print' refers to messages for users. They MUST always be printed.
      A2. 'log' refers to messages for programmers. They MUST be printed only
          if DEBUG is set in the environment and MUST be preceded by ' [log] '.

    A3.1. Before parsing the user arguments, a configuration file at
          $XDG_CONFIG_DIR/tori/tori.conf MUST be read for a line such as:
          'su_command = doas'.
    A3.2. If this line is not found, the su_command MUST default to 'su -c'.
    A3.3. If it is found, the su_command used MUST be whatever was specified.
    A3.4. Whatever su_command MUST be validated once for presence at the path
          provided or obtained from $PATH, executability and running 'true'
          with exit code 0.

      A4. The 'command' is the first argument passed to the program.
      A5. The 'arguments' are all but the first argument passed to the program.
      A6. If a command takes no arguments, they MAY be silently ignored.

    B1.1. The commands in the listing below MUST all be implemented
    B1.2. In the listing below, the left side of '->' is the command, and the
          right side is the action to be taken when this command is provided
    B1.3. In the listing below, the pipe symbol '|' means 'or'

    B2.1. version | -v | --version -> MUST print the version as in v0.8.0
    B2.2. help | -h | --help -> MUST print '<long help>'
    B2.3. os -> MUST print the contents of /etc/os-release
    B2.4. user -> MUST print the output of the 'whoami' command
    B2.5. pkg p -> MUST call the system package manager using the su_command
          to install and then uninstall package p. The user MUST be able to
          freely input to these commands' interactive inputs before control
          is returned. When done, it MUST log 'Done:', a newline, and the
          system commands executed, one per line. If no p is provided, it
          MUST NOT run any system commands and print a message
    B2.6. echo x y z -> MUST print x y z
    B2.7. echo -> MUST NOT print any output and exit with status code 0
    B2.8. [no input] -> MUST NOT print any output and exit with status code 0
    B2.9. [any other input] -> MUST print 'Unrecognized command: [command]',
          a newline, '<short help>' and exit with status code 1

      Z1. for the implementation to be 'finished', tests MUST cover all of its
          requirements and these tests MUST pass consistently

