This file tests this tori implementation against the Iganaq Napkin Spec v0

B2.1. version | -v | --version -> MUST print the version as in v0.8.0

  $ tori version
  v0.8.0

  $ tori -v
  v0.8.0

  $ tori --version
  v0.8.0

B2.2. help | -h | --help -> MUST print '<long help>'

  $ tori help
  <long help>

  $ tori -h
  <long help>

  $ tori --help
  <long help>

B2.3. os -> MUST print the contents of /etc/os-release

  $ os_release=$(cat /etc/os-release)
  $ tori_os=$(tori os)
  $ test -n "$os_release"
  $ test -n "$tori_os"
  $ test "$os_release" = "$tori_os"

B2.4. user -> MUST print the output of the 'whoami' command

  $ whoami=$(whoami)
  $ tori_user=$(tori user)
  $ test -n "$whoami"
  $ test -n "$tori_user"
  $ test "$whoami" = "$tori_user"

B2.6. echo x y z -> MUST print x y z

  $ tori echo x y z
  x y z

B2.7. echo -> MUST NOT print any output and exit with status code 0

  $ tori echo

B2.8. [no input] -> MUST NOT print any output and exit with status code 0

  $ tori

B2.9. [any other input] -> MUST print 'Unrecognized command: [command]',
a newline, '<short help>' and exit with status code 1

  $ tori unrecognized_command
  Unrecognized command: unrecognized_command
  <short help>
  [1]
