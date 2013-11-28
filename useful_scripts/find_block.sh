# usage:  ./find_block.sh [target_file] [target_partition]

############ BEGIN SCRIPT ######################
#!/bin/sh

self="$0"

 #`'~.~'^\_/^*-..-*`'~.~'^\_/^*-..-*`'~.~'^\_/^*-..-*`'~.~'^\_/^*\
 #                                                                *
 # function defs, helps with staying posix compliant              |
 #                                                                *
 #_.~*~._/^\_,-''-._.~*~._/^\_,-''-._.~*~._/^\_,-''-._.~*~._/^\_,/

# a simple posix compliant echo command
echo () { printf %s\\n "$*" ; }
inform () { printf %s\\n "[*] $*" ; }

# usage
usage()
{
  err_lev=$1
  echo
  echo "Usage:  $self target_file target_partition"
  echo
  echo "target_file is the file for which you want to find the fs block."
  echo "target_partition is the partition on which target_file can be found."
  echo
  if [[ -n "$err_lev" ]]; then exit $err_lev;fi
}

if [[ $* -ne 2 ]]; then usage 255;fi
target_file="$1"
target_part="$2"

# posix compliant basename
basename()
{
    _basename "$@" &&
    printf "%s\n" "$_BASENAME"
}

_basename() ##
{
    [ "$1" = "--" ] && shift
    fn_path=$1
    fn_suffix=$2
    case $fn_path in
        ## The spec says: "If string is a null string, it is
        ## unspecified whether the resulting string is '.'  or a
        ## null string. This implementation returns a null string
        "") return ;;
        *)  ## strip trailing slashes
            while :
            do
              case $fn_path in
                  */) fn_path=${fn_path%/} ;;
                  *) break ;;
              esac
            done
            case $fn_path in
                "") fn_path="/" ;;
                *) fn_path=${fn_path##*/} ;;
            esac
            ;;
    esac
    case $fn_path in
    $fn_suffix | "/" ) _BASENAME="$fn_path" ;;
        *) _BASENAME=${fn_path%$fn_suffix}
    esac
}

get_path() {
  # $1 is command to check, it's basename will be fed to which to see if one exists in path
  # e.g. if args are /bin/ifconfig eth0, this function will probably return /sbin/ifconfig eth0
  # if which finds ifconfig there in the path, otherwise /bin/ifconfig eth0 will be returned
  base=`basename "$1"`
  c=`which "$base"`
  if test -z "$c"; then c="$1";fi
  shift
  echo "$c" "$@"
}

run_path() {
  # $1 is command to check, it's basename will be fed to 'which' to see if one exists in path
  # e.g. if args are /bin/ifconfig eth0, this function will probably run /sbin/ifconfig eth0
  # if which finds ifconfig there in the path, otherwise /bin/ifconfig eth0 will be run
  base=`basename "$1"`
  c=`which "$base"`
  if test -z "$c"; then c="$1";fi
  shift
  "$c" "$@"
}

get_block_size() {
  # $1 is the target partition, like /dev/sda1
  # using dump2efs for now
    bs=`run_path /sbin/dumpe2fs "$1" | grep 'Block size' | tr -d " " | cut -d ':' -f 2`
  # end dump2efs method

  echo $bs
}

get_inode() {
  # $1 is the target file, like /test.txt
  # using ls -i for now
    i=`run_path /bin/ls -i "$1" | cut -d " " -f 1`
  # end ls -i method
  # alt method using debugfs # /inode/number/0/0/$target_file/7/
    # debugfs $target_part -R "ls -pd" | grep $1 | cut -d '/' -f 2
  # end debugfs method

  echo $i
}

get_block(){
  # $1 is the target partition, $2 is the inode
  # ghetto
  # if extent do this
  tmp=`run_path /sbin/debugfs "$1" -R "stat <${2}>" | grep -A 1 EXTENTS | tail -n 1 | tr -d " " | cut -d ":" -f 2`
  # if fragmented, you get something like:  (0-399): 59820544-59820943
  blk=`echo $tmp | cut -d "-" -f 1`

  echo $blk
}

# get block_size
block_size=`get_block_size $target_part`
echo "block size is:$block_size"
# get inode
inode=`get_inode "$target_file"`
echo "inode is:$inode"
# get block/extent
block=`get_block $target_part $inode`
echo "block is:$block"

echo "Performing bulk extraction test on your targeted area of disk"
run_path /bin/dd if=$target_part bs=$block_size skip=$block count=10 | `get_path /usr/bin/strings`
#run_path /bin/dd if=$target_part bs=$block_size skip=$block count=10 | `get_path /usr/bin/strings` | `get_path /bin/egrep` '\b(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)'
