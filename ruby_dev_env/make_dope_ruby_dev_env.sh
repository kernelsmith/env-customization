#!/usr/bin/env bash

#
# Usage:  see usage function definition
#
# NOTE:  bash version >= 3.2 is required.  Use bash --version to verify

#
# Function Defs
#

# Simple IO functions
function puts {
	# echos '[*] ' and arguments with the -e and -n flags (to stdout)
	# only print something if quiet is empty
	if [ -z "$QUIET" ]; then
		echo -en "[*] $@"
	fi
}
function eqo {
	# echos the arguments if quiet is false
	# only print something if quiet is empty
	if [ -z "$QUIET" ]; then
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
	#  and implode is called (attempt to remove all the damage so far)
	# echos '[!] ' and first argument with the -e and -n flags and redirect to stderr
	# if a second argument is given, this function will exit with that argument as the code
	echo -en "[-] $1" >&2
	if [ $2 ]; then implode && exit $2;fi
}

# Functional functions

function for_each_ver {
	# this fxn just runs $cmd ${thing}$ver, so $ver is appended to end of thing
	# $1 should be the command to run on each thing
	cmd="$1"
	# $2 should be a list of things to do for each ver
	things="$2"
	for ver in $RUBY_VERS; do 
		for thing in $things; do 
			$cmd ${thing}$ver
		done
	done
}

function cleanup {
	# Called after successful or unsuccessful install, so shouldn't be destructive
	# Instead see the implode function if you want to undo the damage you've done
	apt-get autoremove
}

myself="$0"
function usage {
	# if arguments provided, assume they are warning messages to be displayed
	echo
	if [ -n "$1" ]; then warn "$@";fi
	echo "Usage: $myself [multi|single]"
	echo "Multi is multi-user mode (or system-wide), must be run with sudo (NOT as root)"
	echo "Single is single-user mode, run script as that user"
}

function validate_options {
	# Validates options and calls usage if any fail

	# we only expect one argument
	if [ ! $# == 1 ]; then usage "Wrong number of arguments" && exit 1;fi
	#check that the argument is kickass
	if [ "$1" == "single" ] || "$opt" == multi ]]; then usage "Unrecognized argument" && exit 1;fi
	mode="$1"
}

function get_user_home {
	# argument is assumed to be a complete user name
	if [ -z "$1" ]; then die "No user given\n" "0";fi
	check_valid_users "$u"
	echo $(grep ^$u: /etc/passwd | cut -d":" -f6)
}

function implode {
	# Called when catastrophic failure or interrupted, it attemps to undo everything

	# rvm implode, and in case that doesn't work, also run the script from 
	# http://beginrescueend.com/support/troubleshooting/#remove

	rvmsudo rvm implode || rvm implode
	/usr/bin/sudo rm -rf $HOME/.rvm $HOME/.rvmrc /etc/rvmrc /etc/profile.d/rvm.sh /usr/local/rvm /usr/local/bin/rvm
	/usr/bin/sudo /usr/sbin/groupdel rvm
	puts "RVM is removed. Please check all .bashrc|.bash_profile|.profile|.zshrc for 
RVM source lines and delete or comment out if this was a Per-User installation."

	# purge every package we've installed so far
	apt-get -y purge $aptq
}

function apt_que {
	# let's track everything we install so we can remove it if need be
	$aptq="${aptq} $@"
	apt-get -y install "$@"
}

function install_RVM {
	#
	# Install RVM
	#
	# TODO:  if statement and install differently if single mode
	if "$mode" == "single"; then
		die "Homey don't play dat right now" 99
	else # multi
		#warn "Manually skipping rvm intall for now\n"
		puts "Installing rvm in multi-user mode\n"
		puts "--> See: http://beginrescueend.com/rvm/install/ for details or if troubles"
		if [ -z "$(which curl)" ]; then
			# no curl, let's install it
			puts "Installing curl\n"
			apt_que -y install curl
		fi
	
		puts "Curling\n"
		# !! IMPORTANT !! this is where it's critical this script be run with sudo, NOT as root
		#				for details see: http://beginrescueend.com/support/troubleshooting/#sudo
		bash < <( curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer )
	
		puts "Adding users $USERS to the rvm group, you'll have to add others yourself\n"
		for user in $USERS; do usermod -a -G rvm $user;done
	
		# Update bashrc_profile for each user
		#for user in $USERS; do
		#	basher=$(get_user_home $user)/.bashrc_profile
		#	if ! $(grep -q "Load RVM source" $basher); then
		#		puts "Updating bashrc_profile for $user\n"
		#		# in multi user mode, bashrc is updated for eveyone by creating
		#		# /etc/profile.d/rvm.sh.  We will source that here, but you may need to log out and in
		#		echo "# Enable Tab Completion in RVM
	#[[ -r /usr/local/rvm/scripts/completion ]] && source /usr/local/rvm/scripts/completion" >> $basher
	#		fi
	#	done
		echo "[[ -r /usr/local/rvm/scripts/completion ]] && source /usr/local/rvm/scripts/completion" >> /etc/profile.d/rvm.sh
		source /etc/profile.d/rvm.sh
	fi # end mode if
}

function install_rubies {
	for ver in $@; do 
		puts "Installing ruby $ver\n"
		if $(echo $ver | grep -q '1.9'); then
			# if we're installing a 1.9* version, we need to make sure of some things
			# installing zlib is required for the rvm install 1.9.1
			#apt_que -qq install libzlib-ruby zlibc zlib-bin
			#rvm pkg install zlib
			# rvm install $ver -C --with-zlib-dir='$rvm_path'/usr
			rvm install $ver
		else
			# just do the install
			#warn "Skipping rvm install $ver"
			rvm install $ver
		fi
	done
}

function configure_irbrc {
	#configure irb http://ruby-doc.org/docs/ProgrammingRuby/html/irb.html
	# $@ is a list of users for which to configure
	for user in $@; do
		irbrc="$(get_user_home $user)/.irbrc"  #let's assume ~/.irbc for now
		puts "Updating $irbc\n"
		echo "puts \"Loading $irbrc\""  >> $irbrc
		echo "require 'rubygems'" >> $irbrc
		echo "require 'wirble'" >> $irbrc
		echo "require 'irb/completion'" >> $irbrc
		echo "Wirble.init" >> $irbrc
		echo "Wirble.colorize" >>$irbrc
		echo -e "class Object\n\t# get all the methods for an object that aren't basic methods from Object\n\tdef local_methods\n\t\t(methods - Object.instance_methods).sort\n\tend\nend"
	done
}

function ifdo {
	# $1 is what to check for nonzero length, $2 is what to execute
	if [ -n "$1" ]; then echo "running $2" && eval "$2";fi
}

# TRAPS
trap ' warn "Caught interrupt signal... trying to revert everything" && implode && cleanup ' ABRT HUP INT TERM QUIT

#
# END Function Defs
#

# -- Prep --
# Whether to be quiet, anything but an empty string is considered true 
QUIET=''
# Check for valid usage & set the mode
#validate_options "$@"

#
# Configuration
#

# List of ruby versions to install with rvm
RUBY_VERS="1.9.2"
# Version of ruby to set as system default
RUBY_DEFAULT_VER="1.9.2"
# List of gems that always get installed
ALWAYS_GEMS="hpricot sqlite3 pg wirble mysql"
# List of packages that always get installed
ALWAYS_PKGS=""
# Nokogiri has some special dependencies...
# Whether to install Nokogiri.  Anything but an empty string is considered true
INSTALL_NOKO="true"
# List of additional packages to install.
# dradis:  rubygems libsqlite3-0 libsqlite3-dev libxml2-dev libxslt1-dev
MY_PKGS="libsqlite3-0 libsqlite3-dev libxml2-dev libxslt1-dev"
# List of additional gems to install.  Installed after all other actions.
MY_GEMS="bundler rest-client mechanize"
# For now, just get the *real* user running this script
USERS=$(who am i | cut -d" " -f1)

#
# END Configuration
#

source "$HOME/.rvm/scripts/rvm"
puts "Updating apt cache\n"
apt-get -qq update
# install git if needed
if [ -z "$(which git)" ]; then
	puts "Installing git-core\n"
	apt_que git-core
fi

#ifdo "$INSTALL_RVM" "install_RVM"
#ifdo "$RUBY_VERS" "install_rubies $RUBY_VERS"

puts "Installing gems:$ALWAYS_GEMS\n"
ifdo $ALWAYS_GEMS "rvm gem install $ALWAYS_GEMS"
puts "Setting ruby default to $RUBY_DEFAULT_VER\n"
ifdo "$RUBY_DEFAULT_VER" "rvm $RUBY_DEFAULT_VER --default"

#ifdo "$USERS" "configure_irbrc $USERS"

# NOKOGIRI
if [ -n "$INSTALL_NOKO" ]; then
	puts "Installing Nokogiri and it's dependencies\n"
	# TODO:  need to check what rvm has already installed, see if ri,irb etc are included
	# dev_packages="ruby-dev ri rdoc irb"

	# this seems unnec if rvm install 1.9.2 was performed
	#dev_packages="libreadline-ruby libopenssl-ruby"
	#puts "\tInstalling $dev_packages\n"
	#for_each_ver 'apt_que' $dev_packages

	packages="libxslt1-dev libxml2-dev"
	puts "\tInstalling $packages\n"
	for pkg in $packages; do apt_que $pkg;done

	# rvm gem install nokogiri, this will install gem into all versions rvm knows about
	puts "\tInstalling Nokogiri gem\n"
	rvm gem install nokogiri
fi

# MY PACKAGES
if [ -n "$MY_PKGS" ]; do
	puts "Installing additional packages:  $MY_PKGS\n"
	for pkg in $MY_PKGS; do puts "\tInstalling pkg: $pkg\n" && apt_que $pkg;done
fi

# MY GEMS
# 	Do this last in case it depends on anything above
if [ -n "$MY_GEMS" ]; do
	puts "Installing additional gems:  $MY_GEMS\n"
	for gem in $MY_GEMS; do puts "\tInstalling gem: $gem\n" && rvm gem install $gem;done
fi


: <<-EOF
apt-get -y install git-core
apt-get -y install curl
bash < <( curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer )
edit "$HOME/.bashrc
source "$HOME/.bashrc"
# 1.9.2 stuff isn't in default ubuntu libs
rvmsudo apt-get install libreadline-ruby1.9.2 libopenssl-ruby1.9.2 libxslt1-dev libxml2-dev
rvm gem install hpricot wirble pg
rvm $RUBY_DEFAULT_VER --default
sudo apt-key adv --keyserver pgp.mit.edu --recv-keys 81C0BE11
sudo add-apt-repository ppa:ubuntu-on-rails/pp
sudo apt-get install libreadline-ruby1.9.2 libruby1.9.2
rvm gem install nokogiri rest-client mechanize bundler sqlite3 sqlite3-ruby
EOF
