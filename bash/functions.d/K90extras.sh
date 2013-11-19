#
# Cool stuff that one does not often need
#

# method to help cleanup after sensitive scripts
# this is likely incomplete & requires editing
function cleanup {
  # "remove" all the remnants
  puts "Cleaning up..."

  # change back to the original directory first
  cd $origdir

  #-directories
  fastrm $builddir

  #-variables/"constants"
  for c in $(set | grep '^_ERR_' | cut -d'=' -f1); do unset ${v}; done
  for v in "builddir btisoname myself mypid"; do unset ${c}; done

  #-functions?  ugh.
  #unset -f fxnname
  puts "Done."
}
export -f cleanup

# displays a countdown timer which doesn't take up space or add \n
function countdown {
  seconds=$1
  : ${seconds:=120}
  while [ $seconds -gt 0 ]
  do
    sleep 1 &
    printf "\r%02d" $seconds
    seconds=$(( $seconds - 1 )) # this is another way of doing "let"
    wait
  done
  echo
}
export -f countdown

# VERY useful for mass deleting high numbers of files at once, rm is quite slow
function fastrm {
  # if perl is readily available, use it's 'unlink' to remove stuff, it's much faster than 'rm'
  # This is a hack to keep the syntax the same as that for 'rm' and to avoid
  #  invoking 'perl -nle' a bunch of times, which would be somewhat counterproductive
  #  There's probably a smarter way using 'xargs' or something or maybe some crazy 'find'
  if [ $(which perl) ] &> /dev/null; then
    templist=
    # convert space-separated list into new-line-separated list
    # there's probably a better way to handle this, but hey, ghetto FTW!
    for item in "$@"; do templist="${templist}${item}\n";done
    echo -en $templist | perl -nle unlink
  elif [ $(which ruby) ] &> /dev/null; then
      templist=
      for item in "$@"; do templist="${templist}${item}\n";done
      echo -en $templist | ruby -nle 'File.unlink $_'
    fi
  else
    # else use rm -rf as the fall back
    rm -rf "$@"
  fi
}
export -f fastrm

# narrow use cases, it chroots a new shell and drops you in it while changing
# the prompt to tell you how to get out of the new shell
# this function was developed to help with editing filesystems such as a squashfs
# that was mounted for editing, such as with the old backtrack iso edit script
function interact {
  echo
  echo
  puts "Starting interactive shell, type 'exit' when done\n"
  oldPS1="$PS1"
  export PS1='[Interacting with iso.  Enter exit to exit chroot] # '
  chroot edit
  PS1="$oldPS1"
  puts "Exited the interactive shell\n"
  echo
  echo
}
export -f interact

# not something we really need to export, this is more of a template
function usage {
  if [ -n "$1" ]; then warn "$@";fi # depends on warn (input_output function)
  echo
  echo "Usage:  $myself input-iso [-o output-iso] [-t] [-s] [-q]"
  echo "  -o name the output file output-iso instead of bt4-mod.iso"
  echo "  -t append a sortable timestamp (YrMoDay-HrMinSec) to the output file (no clobber)"
  echo "  -s definitely provide an interactive shell (requires interaction to complete)"
  echo "  -q be quiet, only give warnings and errors, don't provide a shell (overrides -s)"
  echo "Examples:"
  echo "  $myself /isos/bt4.iso -o mybt4.iso -t -q"
  echo "  Takes /isos/bt4.iso and produces mybt4.iso.20110429-235609 in the current dir"
}