# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# NOTE:  I only maintain the additions to this file as I don't currently
# want to overwrite the entire default version.  This file should be
# appended to the end of the default version.  See the
# augment_my_env.sh script

# To enable debug output, uncomment the following line.  It may have
#   already been enabled in a previously sourced file like .bash_profile
export DEBUG_DOT_FILES="true" && current="~/.bash_rc"
[ -n "$DEBUG_DOT_FILES" ] && echo "Running inside $current"

# enable color support of ls and also add handy aliases
# NOTE, moved to aliases.d which runs after bashrc. Whichever runs last, wins.

# Set the default editor
export EDITOR=/usr/bin/vim

# Possibly load additional setup from drop directories
script="~/load_drop_directories.rc"
[ -n "$DEBUG_DOT_FILES" ] && echo "sourcing $script if available"

# Edit the load_drop_directories.rc file above to fine tune file loads, or
# you can comment out the source line below to disable the load entirely (or
# you can remove/rename the rc file)
# source $script if it's a regular file which is executable and non-zero-length
[ -f "$script" -a -x "$script" -a -s "$script" ] && source $script

# export a var to indicate bashrc has been run
[ -n "$DEBUG_DOT_FILES" ] && echo "Setting BASHRC_COMPLETE to true"
export BASHRC_COMPLETE="true"
