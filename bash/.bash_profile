export IS_OSX=$(uname -a | grep Darwin) # close enuf for me

# Note, in Linux bashrc is run automatically for any non-login shell, however
# OS X by default runs ~/.bash_profile, hence the code below
# run ~/.bashrc if it is executable and non-zero length
bashrc="~/.bashrc"
[ -n "$IS_OSX" -a -x "$bashrc" -a -s "$bashrc" ] && source "$bashrc"