# ~/.bash_profile generally gets executed from the following sequence
#   when logging in via an INTERACTIVE LOGIN, see below for more
# 1) execute /etc/profile
# then execute the FIRST of the following which exists and is readable
# 2a) ~/.bash_profile # <-- often (but not always) sources ~/.bashrc
# 2b) ~/.bash_login
# 2c) ~/.profile

# AN INTERACTIVE LOGIN is typically when you login at a TTY by hitting
#   Ctrl+Alt+F2 etc or when logging in via SSH.  You can check if
#   BASH was started as a login-shell by running:
#   shopt login_shell  # => if result is 'on' then it's a login shell

# NOTE:  I only maintain the additions to this file as I don't currently
# want to overwrite the entire default version.  This file should be
# appended to the end of the default version.  See the
# augment_my_env.sh script

export INDENT_VAL="  " # value used for indentation
export indent="" # the current total indentation to use

#
# DEBUGGING
#
# To enable debug output, uncomment the following line
export DEBUG_DOT_FILES="true"
debug() {
  [ -n "$DEBUG_DOT_FILES" ] && echo "$indent[DEBUG] $@"
}
export -f debug # make this debug function available to child shells

current=".bash_profile" # can't use $0 going forward as the files are sourced, not ran
debug "Running inside $current"

IS_OSX=$(uname -a | grep Darwin) # close enuf for me
# export IS_OSX if we end up needing it elsewhere

# Note, in Linux bashrc is sometimes run automatically for any non-login shell
# by ~/.bash_profile or other dot file, however, OS X by default runs just
# ~/.bash_profile, hence the code below.  Additionally, it varies in Linux,
# so we are going to try to handle that.
# run ~/.bashrc if it is executable and non-zero length
script="$HOME/.bashrc"
if [ -n "$IS_OSX" ]; then
  debug "We are running in OS X so sourcing $script"
  # update PATH, xcode has its own git and it's crappy, we want ours from /usr/local/bin
  export PATH="/usr/local/bin:$PATH"
  indent+="$INDENT_VAL"
  [ -f "$script" -a -x "$script" -a -s "$script" ] && source "$script"
elif [ -n "$BASHRC_COMPLETE" ]; then
  # then it's likely that it's NOT already been run, or didn't complete
  # BASHRC_COMPLETE is defined and exported when my bashrc file completes
  debug "Doesn't seem bashrc has been run, so sourcing $script"
  indent+="$INDENT_VAL"
  [ -f "$script" -a -x "$script" -a -s "$script" ] && source "$script"
fi
indent="" # reset the current indent
# Finally, call any functions we want to actually be run
# NOTE:  If the env var MYPROXY is set, it will affect these proxy functions
echo "[*] Turning on the CLI proxies from $current."
proxyon
echo "[*] The current state of CLI proxy variables:"
proxystate