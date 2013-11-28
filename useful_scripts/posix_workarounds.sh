
# a simple posix compliant echo command
echo () { printf %s\\n "$*" ; }
inform () { printf %s\\n "[*] $*" ; }

# a more complex posix compliant echo command which mimics
# bash's echo cmd with -e and -n as possible switches
echoen () {
  fmt=%s end=\\n IFS=" "
  while [ $# -gt 1 ] ; do
    case "$1" in
     [!-]*|-*[!ne]*) break ;;
     *ne*|*en*) fmt=%b end= ;;
     *n*) end= ;;
     *e*) fmt=%b ;;
    esac
      shift
  done
  printf "$fmt$end" "$*"
}
