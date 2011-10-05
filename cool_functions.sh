#
#define some fxns
#
function puts {
	# echos '[*] ' and arguments with the -e and -n flags (to stdout)
	# only print something if quiet is empty
	if [ -z "$quiet" ]; then
		echo -en "[*] $@"
	fi
}
function eqo {
	# echos the arguments if quiet is false
	# only print something if quiet is empty
	if [ -z "$quiet" ]; then
		echo "$@"
	fi
}
function warn {
	# warnings, i.e. non-fatal errors to stdout
	# echos '[-] ' and arguments with the -e and -n flags (to stdout)
	echo -en "[-] $@"
}
function die {
	# fatal or nearly-fatal errors, if you give a second argument, it is used as an exit code
	# echos '[!] ' and first argument with the -e and -n flags and redirect to stderr
	# if a second argument is given, this function will exit with that argument as the code
	echo -en "[-] $1" >&2
	if [ $2 ]; then exit $2;fi
}

function chk_mkdir {
	# make a directory (with -p) if it doesn't exist
	if [ ! -d "$1" ]; then 
		# make the directory, or fail out
		mkdir -p $1 ||	err "Can't write to current directory...aborting" $_ERR_CANT_WRITE_DIR
	fi
}

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

function fastrm {
	# if perl is readily available, use it's 'unlink' to remove stuff, it's much faster than 'rm'
	# This is a hack to keep the syntax the same as that for 'rm' and to avoid
	#  invoking 'perl -nle' a bunch of times, which would be somewhat counterproductive
	#  There's probably a smarter way using 'xargs' or something or maybe some crazy 'find'
	if [ $(which perl) ] &>/dev/null; then
		templist=
		for item in "$@"; do templist="${templist}${item}\n";done
		echo -en $templist | perl -nle unlink
	else 
		if [ $(which ruby) ] &>/dev/null; then
			templist=
			for item in "$@"; do templist="${templist}${item}\n";done
			echo -en $templist | ruby -nle 'File.unlink $_'
		fi
	else
	# else use rm -rf as the fall back
		rm -rf "$@"
	fi
}

function cleanup {
	# "remove" all the remnants
	puts "Cleaning up..."
	
	# change back to the original directory first
	cd $origdir
	
	#-directories
	fastrm $builddir
	
	#-variables/"constants"
	for c in $(set | grep '^_ERR_' | cut -d'=' -f1); do unset ${v}; done
	for v in "builddir btisoname myself	mypid"; do unset ${c}; done
	
	#-functions?  ugh.
	#unset -f fxnname
	puts "Done."
}

function stampit {
	echo "$@.$(date +%Y%m%d-%H%M%S)"
}

function usage {
	if [ -n "$1" ]; then err "$@";fi
	echo
	echo "Usage:	$myself input-iso [-o output-iso] [-t] [-s] [-q]"
	echo "	-o name the output file output-iso instead of bt4-mod.iso"
	echo "	-t append a sortable timestamp (YrMoDay-HrMinSec) to the output file (no clobber)"
	echo "	-s definitely provide an interactive shell (requires interaction to complete)"
	echo "	-q be quiet, only give warnings and errors, don't provide a shell (overrides -s)"
	echo "Examples:"
	echo "	$myself /isos/bt4.iso -o mybt4.iso -t -q"
	echo "	Takes /isos/bt4.iso and produces mybt4.iso.20110429-235609 in the current dir"
}

#
# TRAPS
#
trap ' err "Caught interrupt signal... cleaning up" && cleanup ' ABRT HUP INT TERM QUIT
