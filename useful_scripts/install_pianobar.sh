#!/bin/bash
 
# a folder called 'pianobar' will be created in the install dir and files downloaded
#  and compliled will go there
INSTALL_DIR="/usr/local/src"
PKGS="build-essential libao-dev libmad0-dev libfaad-dev"
 
function echo2(){
        echo "[*] $1"
}
 
echo2 "Installing required packages if nec"
apt-get install -y $PGKS
 
echo2 "Install directory will be $INSTALL_DIR/pianobar"
tar_site="http://github.com/PromyLOPh/pianobar/tarball/master"
## I'm just gonna assume you have wget, if not, shame shame!
echo2 "Downloading the pianobar tarball"
wget $tar_site -O ${INSTALL_DIR}/pianobar.tgz
echo2 "Untarring/Gunzipping"
tar -C $INSTALL_DIR -xzf ${INSTALL_DIR}/pianobar.tgz
## the tarball has a really weird folder name in it, so let's name it something nicer
mv ${INSTALL_DIR}/PromyLOPh* ${INSTALL_DIR}/pianobar/
echo2 "Compiling pianobar"
make -C ${INSTALL_DIR}/pianobar clean
make -C ${INSTALL_DIR}/pianobar
echo2 "Installing"
make -C ${INSTALL_DIR}/pianobar install
echo2 "Creating softlink in /usr/bin"
# create a softlink to pianobar in /usr/bin so it will be in our paths going forward
ln -sf $INSTALL_DIR/pianobar/pianobar /usr/bin/pianobar
 
# optional, create a config file at ~/.config/pianobar/config
# keep in mind where you want this config, ie /root or /home/user etc, if running this as root
# best thing to do is run this with sudo so you're home dir will not become /root
echo2 "Copying example config to ~/.config/pianobar, dir will be created"
config_dir="~/.config/pianobar"
mkdir -p $config_dir
cp ${INSTALL_DIR}/pianobar/contrib/config-example ${config_dir}/config
# edit the config, most notably:  user, password, and autostart_station
# to get your station id, press 'i' while pianobard is running, it's ~18 digit number
echo2
echo2 "#####################################################################"
echo2 "Use your favoriite editor to edit the config such as:  vim ${config_dir}/config"
echo2 "You'll probably want to edit user, password, and autostart_station, but up to you"
echo2 "#####################################################################"
echo2
 
# cleanup
rm -rf $INSTALL_DIR/pianobar.tgz
 

