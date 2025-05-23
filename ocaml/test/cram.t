This file tests this tori implementation against the Iganaq Napkin Spec v0.2

A2. 'log' MUST print only if DEBUG is set and MUST be preceded by ' [log] '

  $ without_debug=$(tori os 2>&1)
  $ with_debug=$(DEBUG=os tori os 2>&1)
  $ test "$without_debug" != "$with_debug"
  $ echo "$with_debug" | grep -Fq " [log] "
  $ echo "$without_debug" | grep -Fqv " [log] "

A3.2. if su_command is unset, the default must be 'su -c'

  $ echo 'simulate=true' > $HOME/.config/tori/tori.conf
  $ DEBUG=1 tori pkg xterm 2>&1 | grep -Fq 'su -c'

A3.3. if su_command is set, su_command must be the set value

  $ echo 'simulate=true' > $HOME/.config/tori/tori.conf
  $ echo 'su_command=doas' >> $HOME/.config/tori/tori.conf
  $ DEBUG=1 tori pkg xterm 2>&1 | grep -Fq 'doas'

A3.4. [config] su_command must be validated for presence at the provided path
or a path obtained from $PATH and filesystem permission to execute

  $ echo 'su_command=sudo' > $HOME/.config/tori/tori.conf
  $ ! which sudo >/dev/null || tori 2>&1 >/dev/null
  $ echo 'su_command=doas' > $HOME/.config/tori/tori.conf
  $ ! which doas >/dev/null || tori 2>&1 >/dev/null

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

B2.3. os -> MUST print the os name

  $ os_name=$(cat /etc/os-release | grep '^NAME=' | cut -d= -f 2 | sed 's/"//g')
  $ tori_os=$(tori os)
  $ test -n "$os_name"
  $ test -n "$tori_os"
  $ test "$os_name" = "$tori_os"

B2.3. os -> MUST log the contents of /etc/os-release

  $ tori_os=$(DEBUG=os tori os 2>&1)
  $ test -n "$tori_os"
  $ echo "$tori_os" | grep -qFf /etc/os-release

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
