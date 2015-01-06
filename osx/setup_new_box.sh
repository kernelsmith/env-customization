#!/bin/sh
#
# script to setup a new host
#

# Script control:
DO_HOSTNAME=1
HNAME=biggeek

DO_PROXY=1
MYPROXY="http://proxy.houston.hp.com:8080"

DO_XCODE_CLI_TOOLS=1

DO_BREW=1
DO_PORTS=0
PKG_MGR='0'
if [ $DO_BREW -eq 1 ]; do
  PKG_MGR='brew'
elif [ $DO_PORTS -eq 1 ]; do
  PKG_MGR='sudo port'
fi

DO_GPG=1

DO_SUBLIME=1
SUBLIME_URL="http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%20Build%203065.dmg"
DO_VIM=0

# TODO: wireshark?, SSL Cert?, SSH Key?
# DO_WIRESHARK_DEV=1
# WIRESHARK_URL="http://wiresharkdownloads.riverbed.com/wireshark/osx/Wireshark%201.99.0%20Intel%2064.dmg"

DO_VPN_PPP=1

# Error constants:
_ERR_CANT_WRITE_DIR=4

#
# Functions
#
# echo can be pretty retarded and sometimes unpredictable, make it less so
# ref: http://www.etalabs.net/sh_tricks.html
echo () {
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

puts() {
  # echos '[*] ' and arguments with the -e and -n flags (to stdout)
  # only print something if quiet is empty
  [ -z "$quiet" ] && echo -en "[*] $@"
  #TODO: I don't think this is posix, it's using test right?
}

eqo() {
  # echos the arguments with no frills, but only if not quiet
  # only print something if quiet is empty
  [ -z "$quiet" ] && echo "$@"
  #TODO: I don't think this is posix, it's using test right?
}

warn() {
  # warnings, i.e. non-fatal errors to stdout
  # echos '[-] ' and arguments with the -e and -n flags (to stdout)
  # only print something if quiet is empty or not empty but less than a value?
  # local quiet_threshold
  # [ $quiet -lt $quiet_threshold ] && echo -en "[-] $@"
  [ -z "$quiet" ] && echo -en "[-] $@"
  #TODO: I don't think this is posix, it's using test right?
}

die() {
  # fatal or nearly-fatal errors, if you give a second argument, it is used as an exit code
  # echos '[!] ' and first argument with the -e and -n flags and redirect to stderr
  # if a second argument is given, this function will exit with that argument as the code
  # NOTE:  $quiet does not affect the output
  echo -en "[!] $1" >&2
  if [ $2 ]; then exit $2;fi
}

# allows you to easily debug variables as varname:varvalue or similar
investigate() {
  # if $3 isn't given, don't prefix output with anything
  local output_prefix='' # could be something like [*]
  if [ -n "$3" ]; then output_prefix="$3";fi

  # if $2 isn't given, default separator to something
  local output_sep=": " # could be ", " ": " etc
  if [ -n "$2" ]; then output_sep="$2";fi

  # if $1 is given, then good, if not, well jeez, don't do anything
  local var2investigate=''
  if [ -n "$1" ]; then
   var2investigate="$1"
   echo -n "${output_prefix}${var2investigate}${output_sep}"
   v='echo -n $'
   v="${v}$(echo -n $var2investigate)"
   eval $v
   echo
  fi
}

chk_mkdir() {
  # make a directory (with -p) if it doesn't exist
  if [ ! -d "$1" ]; then
    # make the directory, or fail out, use 'die' if available
    mkdir -p $1 || type -t die && die "Can't create directory...aborting" $_ERR_CANT_WRITE_DIR
  fi
}

# start from home
cd ~

# make a .ssh dir if nec
chk_mkdir ${HOME}/.ssh

# set hostname
if [ $DO_HOSTNAME -eq 1 ]; do
  puts "Setting hostname"
  hostname $HNAME
fi

# proxy settings
if [ $DO_PROXY -eq 1]; do
  puts "Setting proxy"
  export http_proxy=$MYPROXY
  export https_proxy=$MYPROXY
fi

if [ $DO_XCODE_CLI_TOOLS -eq 1 ]; do
  puts "Installing XCode Command Line Tools"
  xcode-select --install
fi

# Brew  (This will also install xcode command line tools if needed)
if [ $DO_BREW -eq 1 ]; do
  puts "Installing brew"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  brew doctor
elif [ $DO_PORTS -eq 1 ]; do
  puts "Nothing for ports install yet"
fi
# TODO: Is that the correct elif syntax?

# GPG
if [ $DO_GPG -eq 1 ]; do
  puts "Installing gpg"
  $PKG_MGR install gpg
  # for RVM
  if [ $DO_RVM -eq 1 ]; do
    puts "Fetching RVM's public key"
    gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
  fi
fi

#RVM
if [ $DO_RVM -eq 1 ]; do
  puts "Installing RVM"
  \curl -sSL https://get.rvm.io | bash -s stable --ruby
  rvm rvmrc to ruby-version # optional.  can also throw an ignorable error
fi

# other stuff for package manager to install
if [ $PKG_MGR -neq 0 ]; do
  PACKAGES="nmap wget"
  puts "Installing packages: $PACKAGES"
  $PKG_MGR install $BREW_PACKAGES
fi

#
# Editors
#

# Sublime Text 3
if [ $DO_SUBLIME -eq 1 ]; do
  puts "Downloading Sublime Text"
  wget -O sublime_text_3.dmg $SUBLIME_URL
  puts "Installing Sublime Text"
  open sublime_text_3.dmg
  #  soft link sublime
  #  sudo not required if you use ~/bin but you'll need to add ~/bin to $PATH
  puts "Creating soft link"
  sudo ln -s "/Applications/Sublime Text 3.app/Contents/SharedSupport/bin/subl" /usr/bin/subl
  #  set as default editor?
  export EDITOR='subl -w'
fi

# vi/vim
if [ $DO_VIM -eq 1 ]; do
  puts "Configuring vim"
  # what, pkg_mgr install vim?, does that doing anything?
  # Janus?
  export EDITOR='vim'
  puts "Nothing for vim yet"
fi

#
# VPN Stuff
#

# Create PPP network script to make VPN'ing not suck
if [ $DO_VPN_PPP -eq 1 ]; do
  puts "Creating PPP network script"
  cat << EOF > /etc/ppp/ip-up
#!/bin/sh

# Create /etc/ppp if it does not exist (it should tho and is root:wheel 755 on mine)
# Then create /etc/ppp/ip-up as world executable with the following contents:

if [ "${4%%.*}" = "16" ]; then
  /sbin/route add 15.0.0.0/8 $4
else
  if [ "${4%%.*}" = "15" ]; then
    /sbin/route add 16.0.0.0/8 $4
  fi
fi
EOF
fi
