# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# NOTE:  I only maintain the additions to this file as I don't currently
# want to overwrite the entire default version.  This file should be
# appended to the end of the default version.  See the
# augment_my_env.sh script

# To enable debug output, uncomment the following line
export DEBUG_DOT_FILES="true" && current="~/.bash_rc"
[ -n "$DEBUG_DOT_FILES" ] && echo "Running inside $current"

# enable color support of ls and also add handy aliases
# NOTE, moved to aliases.d which runs after bashrc. and will override

# Set the default editor
export EDITOR=/usr/bin/vim

# Possibly load additional setup from drop directories
script="~/load_drop_directories.rc" # Edit this file to fine tune or
# comment out the source line below to disable (or remove/rename the file)
# source $script if it's a regular file which is executable and non-zero-length
[ -f "$script" -a -x "$script" -a -s "$script" ] && source $script

# export a var to indicate bashrc has been run
export BASHRC_COMPLETE="true"