#!/bin/bash

# a dir (GIT_DIR) will be created and a git repo will be cloned there, i.e. src code goes there

INSTALL_DIR="/usr/local/src/pianobar"
SRC_DIR="/usr/local/src/pianobar"
PKGS="git-core build-essential libao-dev libmad0-dev libfaad-dev libjson0-dev"

function echo2(){
 echo "[*] $1"
}

echo2 "Installing required packages if nec"
sudo apt-get install -y $PGKS

echo2 "Downloading the pianobar source code as git repo to ${SRC_DIR}"

# git cloning
sudo git clone https://github.com/PromyLOPh/pianobar.git $SRC_DIR
cd $SRC_DIR

# if *_DIR's don't exist already, make them
for d in "$INSTALL_DIR $SRC_DIR";do
	if ! [ -d "$d" ]; then sudo mkdir -p $d;fi
done
echo2 "Compiling pianobar and installing to $INSTALL_DIR"
sudo make -C ${INSTALL_DIR} clean
sudo make -C ${INSTALL_DIR}
sudo make -C ${INSTALL_DIR} install
echo2 "Creating softlink in /usr/bin"
# create a softlink to pianobar in /usr/bin so it will be in our paths going forward
# altho it might already be in the path if INSTALL_DIR was changed to something in the path
sudo chmod 777 $INSTALL_DIR/pianobar
sudo ln -sf $INSTALL_DIR/pianobar /usr/bin/pianobar

# optional, create a config file at ~/.config/pianobar/config
# keep in mind where you want this config, ie /root or /home/user etc, if running this as root
# best thing to do is run this with sudo so you're home dir will not become /root
echo2 "Copying example config to ~/.config/pianobar, if it doesn't already exist"
echo2 "The dir will be created if it doesn't exist"
CONFIG_DIR="$(readlink -f ~/)/.config/pianobar"
if ! [ -f ${CONFIG_DIR}/config ]; then 
	mkdir -p $CONFIG_DIR
	cp ${INSTALL_DIR}/contrib/config-example ${CONFIG_DIR}/config
fi
# edit the config, most notably: user, password, and autostart_station
# to get your station id, press 'i' while pianobard is running, it's ~18 digit number
echo2
echo2 "#####################################################################"
echo2 "Use your favoriite editor to edit the config such as: vim ${config_dir}/config"
echo2 "You'll probably want to edit user, password, and autostart_station, but up to you"
echo2 "#####################################################################"
echo2

# cleanup
#rm -rf "$SRC_DIR" 	# only do this if SRC_DIR and INSTALL_DIR are different,
#			# you will remove the binary
exit 0
