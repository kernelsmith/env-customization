# NOTE:  I only maintain the additions to this file as I don't currently
# want to overwrite the entire default version.  This file should be
# appended to the end of the default version.  See the
# augment_my_env.sh script

# To enable debug output, uncomment the following line
export DEBUG_DOT_FILES="true" && current="~/.bash_profile"
[ -n "$DEBUG_DOT_FILES" ] && echo "Running inside $current"

IS_OSX=$(uname -a | grep Darwin) # close enuf for me
# export IS_OSX if we end up needing it elsewhere

# Note, in Linux bashrc is sometimes run automatically for any non-login shell
# by ~/.bash_profile or other dot file, however, OS X by default runs just
# ~/.bash_profile, hence the code below.  Additionally, it varies in Linux,
# so we are going to try to handle that.
# run ~/.bashrc if it is executable and non-zero length
script="~/.bashrc"
if [ -n "$IS_OSX" ]; then
  [ -n "$DEBUG_DOT_FILES" ] && echo "We are running in OS X so sourcing $script"
  [ -f "$script" -a -x "$script" -a -s "$script" ] && source "$script"
else if [ -n "$BASHRC_COMPLETE" ]; then
    # then it's likely that it's NOT already been run, or didn't complete
    [ -n "$DEBUG_DOT_FILES" ] && echo "Doesn't seem bashrc has been run, so sourcing $script"
    [ -f "$script" -a -x "$script" -a -s "$script" ] && source "$script"
  fi
fi