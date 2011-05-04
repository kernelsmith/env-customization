#!/bin/bash

# Tested on GNU bash, version 3.2.39(1)-release (i486-pc-linux-gnu)
# Bash script to customize the BackTrack 4 R* iso
# by kernelsmith {kernelsmith \x40 kernelsmith \x2E com}

#
# some "constants"
#
# 	EXIT CODES
_ERR_WRONG_ARGS=41		#wrong number or type of _A_rguments
_ERR_CANT_FIND_ISO=70	#can't _F_ind the source iso file ($btisoname)
_ERR_CANT_MOUNT=77		#can't _M_ount
_ERR_YOU_NOT_ROOT=82	#you're not _R_oot so I can't mount stuff, try 'sudo -i' or 'su -' first
_ERR_CANT_WRITE_DIR=87	#can't _W_rite to a directory

#
# some variables
#
origdir="$(pwd)"
builddir="${origdir}/BUILD"
btisoname=
outname="${origdir}/bt4-mod.iso"
tstamp=
quiet=
shell=
myself="$(basename $0)"
#mypid=$$

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
	# warnings, i.e. non-fatal errors
	# echos '[!] ' and arguments with the -e and -n flags (to stdout)
	echo -en "[!] $@"
}
function err {
	# fatal or nearly-fatal errors, if you give a second argument, it is used as an exit code
	# echos '[-] ' and first argument with the -e and -n flags and redirect to stderr
	# if a second argument is given, this function will exit with that argument as the code
	echo -en "[-] $1" >&2
	if [ $2 ]; then exit $2;fi
}
function chk_mkdir {
	# make a directory (with -p) if it doesn't exist
	if [ ! -d "$1" ]; then 
		# make the directory, or fail out
		mkdir -p $1 ||	err "Cannot write to current directory...aborting" $_ERR_CANT_WRITE_DIR
	fi
}

function interact {
	echo
	echo
	puts "Starting interactive shell, type 'exit' when done\n"
	oldPS1="$PS1"
	export PS1='[Interacting with iso.  Enter exit to exit chroot]# '
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
		# else use rm -rf as the fall back
		rm -rf "$@"
	fi
}

function cleanup {
	
	# "remove" all the remnants
	puts "Cleaning up..."
	
	# change back to the original directory, as we won't always know when this will get called
	cd $origdir
	
	#-stuff that's possibly mounted
	mountain="edit/dev edit/proc squashfs mnt"
	for mounty in $mountain; do
		umount ${builddir}/${mounty} &> /dev/null || warn "Could not unmount ${builddir}/${mounty}\n"
	done
	chroot edit
	
	#-files
	fastrm $outname || warn "Could not remove $outname\n"
	
	#-directories
	fastrm $builddir || warn "Could not remove the build directory:  $builddir"
	
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

######################################################################
# OK, let's do this shiz
######################################################################

if [ -z "$1" ]; then 
	usage "Missing source iso name\n"
	exit $_ERR_WRONG_ARGS
fi
	
btisoname="$(readlink -f $1)"
shift

while getopts 'o:tqsh' OPTION
do
	case $OPTION in
	o)	outname="$OPTARG"
		;;
	t)	tstamp=1
		;;
	q)	quiet=1
		;;
	s)	shell=1
		;;
	h)	usage
		exit 0
		;;
	?)	usage "Unrecognized or missing arguments\n"
		exit $_ERR_WRONG_ARGS
		;;
	esac
done
shift $(($OPTIND - 1))

# check if root
if [[ $EUID -ne 0 ]]; then
  err "You must be root for these shenanigans... sudo?\n" $_ERR_YOU_NOT_ROOT
fi

#
# Validate args
# 
# if $btisoname doesn't exist, then abort
if ! [ -f $btisoname ]; then
	err "Cannot find $btisoname... aborting\n\n" $_ERR_CANT_FIND_ISO
fi
# if can't touch outname, then can't write to destination dir, abort
if ! touch $outname; then
	err "Cannot write to $(dirname $outname)" $_ERR_CANT_WRITE_DIR
fi
outname="$(readlink -f $outname)"

# create the builddir if nec
chk_mkdir $builddir
cd $builddir

clear
puts "----------------------------------------------------------- [*]\n"
puts "BackTrack 4 joshomization script\n"
puts "Setting up the build environment...\n"

chk_mkdir mnt
mount -o loop $btisoname mnt/ || err "Cannot mount the iso (requires -o loop)\n" $_ERR_CANT_MOUNT
chk_mkdir extract-cd
rsync --exclude=/casper/filesystem.squashfs -a mnt/ extract-cd
chk_mkdir squashfs
mount -t squashfs -o loop mnt/casper/filesystem.squashfs squashfs/ || \
err 'Cannot mount the squashfs (requires -t squashfs)\n' $_ERR_CANT_MOUNT
chk_mkdir edit
puts 'Copying over files, please wait ... \n'

puts "...squashfs..."
cp -a squashfs/* edit/
puts "...resolv.conf..."
cp /etc/resolv.conf edit/etc/
puts "...hosts..."
cp /etc/hosts edit/etc/
puts "...fstab..."
cp /etc/fstab edit/etc/
puts "..mtab..."
cp /etc/mtab edit/etc/

eqo

mount --bind /dev/ edit/dev || err 'Cannot mount /dev/ (requires --bind)\n' $_ERR_CANT_MOUNT
mount -t proc /proc edit/proc || err 'Cannot mount /proc (requires -t proc)\n' $_ERR_CANT_MOUNT

puts "----------------------------------------------------------- [*]\n"
puts "Entering the live iso.\n"
puts "----------------------------------------------------------- [*]\n"
puts "If you are running a large update, you might need to stop\n"
puts "services like crond, udev, cups, etc in the chroot\n"
puts "before exiting your chroot environment.\n"
puts "----------------------------------------------------------- [*]\n"
puts "Starting modifications\n"
puts "----------------------------------------------------------- [*]\n"

###############################################################################
# At this point, anything starting with 'chroot edit' is in the build environ

#-------------------------------------------
# 			OS & TOOL(REPO) UPDATES
#-------------------------------------------
puts "Updating the OS with apt-get update and upgrade\n"
chroot edit /usr/bin/apt-get update --fix-missing
chroot edit /usr/bin/apt-get -y upgrade
puts "Cleaning the apt cache\n"
chroot edit /usr/bin/apt-get -y clean

#--------------------------------------------
# 			TOOL SPECIFIC UPDATES
#--------------------------------------------

#update metasploit, note svn update is called directly so server cert issues can be avoided
puts "Updating metasploit\n"
chroot edit cd /opt/metasploit3/msf3/ && /opt/usr/bin/svn update --non-interactive --trust-server-cert
# update fast-track
# command line updating was disabled by the fasttrack author
#chroot edit "cd /pentest/exploits/fasttrack && python fast-track.py -c 1"
# update SET
#chroot edit cd /pentest/exploits/SET && python set-update

#--------------------------------------------
# 			CUSTOM UPDATES
#--------------------------------------------

#NOTE:  You may need to add these to the removal section of the manifest and/or rc
puts "Installing custom packages:  $newinstalls"
newinstalls="vim kde-guidance-kde3 bashish"
for melikey in $newinstalls; do
	apt-get -y install $melikey
done

#--------------------------------------------
# 			MANUAL UPDATES (INTERACTIVE)
#--------------------------------------------

# If quiet not requested, decide on whether to present an interactive shell
if [ -z "$quiet" ]; then
	# first check if shell is already requested
	if [ -n "$shell" ]; then
		interact
	else
		# Ask if they want to enter some manual commands in an interactive shell
		# default is no
		CHOICE="n"
		read -t 30 -p "[-?-] Want to start an interactive shell for manual commands? [y/n] (timeout=30): " 
		echo
		case "$CHOICE" in
			[yY1]) interact;;
			*	) puts "Skipping interactive shell\n";;
		esac 
	fi
fi

#####################################################################
# EXITING THE BUILD ENVIRONMENT
#####################################################################
puts "Exited the build environment, unmounting images...\n"

rm -rf edit/etc/mtab
rm -rf edit/etc/fstab

umount edit/dev || warn "Could not unmount edit/dev\n"
umount edit/proc || warn "Could not unmount edit/proc\n"
umount squashfs || warn "Could not unmount sqashfs\n"
umount mnt || warn "Could not unmount mnt\n"
puts "Done.\n"

chmod +w extract-cd/casper/filesystem.manifest

puts "Building manifest, give me a sec..."
chroot edit dpkg-query -W --showformat='${Package} ${Version}\n' > extract-cd/casper/filesystem.manifest

#
# Remove some services from the rc.d
#
services="inetutils-inetd tinyproxy iodined knockd openvpn atftpd ntop nstxd nstxcd apache2 sendmail atd dhcp3-server winbind miredo miredo-server pcscd wicd wacom cups bluetooth binfmt-support mysql"

for service in $services;do
	chroot edit update-rc.d -f $service remove
done

#
# Remove some entries in the manifest
#
REMOVE='ubiquity casper live-initramfs user-setup discover xresprobe os-prober libdebian-installer4'
for i in $REMOVE;do
	sed -i "/${i}/d" extract-cd/casper/filesystem.manifest-desktop
done

cp extract-cd/casper/filesystem.manifest extract-cd/casper/filesystem.manifest-desktop
puts "Done.\n"

sed -i '/ubiquity/d' extract-cd/casper/filesystem.manifest-desktop

fastrm extract-cd/casper/filesystem.squashfs
puts "Building squashfs image..."

mksquashfs edit extract-cd/casper/filesystem.squashfs
puts "Done.\n"

fastrm extract-cd/md5sum.txt

(cd extract-cd && find . -type f -print0 | xargs -0 md5sum > md5sum.txt)

cd extract-cd

puts "Creating iso..."
mkisofs -b boot/grub/stage2_eltorito -no-emul-boot -boot-load-size 4 -boot-info-table -V "BT4" -cache-inodes -r -J -l -o ${outname} .
puts "Done. \n"

cd $origdir

eqo
eqo
puts "~^~._.~^~._.~^~._.~^~._.~^~._.~^~._.~^~._.~^~._.~^~._.~^~ [*]\n"
puts "Your modified iso is at ${outname}\n"
puts "~^~._.~^~._.~^~._.~^~._.~^~._.~^~._.~^~._.~^~._.~^~._.~^~ [*]\n\n"

exit 0
