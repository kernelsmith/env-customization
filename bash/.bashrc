# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# NOTE:  I only maintain the additions to this file as I don't currently
# want to overwrite the entire default version.  This file should be
# appended to the end of the default version.  See the
# augment_my_env.sh script
# Altho, that's exactly what I'm doing right now

# set to anything to see debug output, otherwise nothing
export DEBUG_BASH_FRAMEWORK=1
debug() {
  if [ -n "$DEBUG_BASH_FRAMEWORK" ];then
    echo "[DEBUG] $@"
  fi
}
export -f debug
orig_indent=$indent
current=".bashrc" # can't use $0 as these files are sourced, not ran
debug "Running inside $current"

# enable color support of ls and also add handy aliases
# NOTE, moved to aliases.d which runs after bashrc. Whichever runs last, wins.

# Set the default editor
export EDITOR=/usr/bin/vim

# Possibly load additional setup from drop directories
script="load_drop_directories.rc"
debug "Sourcing $script if available"

# Edit the load_drop_directories.rc file above to fine tune file loads, or
# you can comment out the source line below to disable the load entirely (or
# you can remove/rename the rc file)
# source $script if it's a regular file which is executable and non-zero-length
indent+="$INDENT_VAL"
[ -f "$script" -a -x "$script" -a -s "$script" ] && source $script
indent=$orig_indent

# export a var to indicate bashrc has been run
debug "Setting BASHRC_COMPLETE to true"
export BASHRC_COMPLETE="true"

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
