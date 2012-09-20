#!/bin/bash

#
# This script will install Metasploit Framework + the unstable tree under /opt/metasploit/
# For Ubuntu.  Tested on Ubuntu 10.10
#

INSTALL_PATH="/opt/metasploit"

echo "Installing required packages...."
sudo apt-get install -y ruby libopenssl-ruby libyaml-ruby libdl-ruby libiconv-ruby libreadline-ruby irb ri rubygems
sudo apt-get install -y subversion
sudo apt-get install -y build-essential ruby-dev libpcap-dev

echo "Downloading Metasploit Framework..."
sudo svn checkout https://www.metasploit.com/svn/framework3/trunk $INSTALL_PATH

echo "Downloading the unstable tree..."
sudo svn checkout https://metasploit.com/svn/framework3/unstable/modules/ $INSTALL_PATH/unstable/

echo "Updating Metasploit..."
cd $INSTALL_PATH
sudo svn update

echo "Creating ~/.msf4/"
echo set LogLevel 5 >> /tmp/msf_load_msf4.rc
echo save >> /tmp/msf_load_msf4.rc
echo exit >> /tmp/msf_load_msf4.rc
cd $INSTALL_PATH
./msfconsole -q -r /tmp/msf_load_msf4.rc
rm /tmp/msf_load_msf4.rc

echo "Adding Metasploit to PATH..."
echo \# Metasploit path >> ~/.bashrc
echo export PATH=\$PATH:$INSTALL_PATH/ >> ~/.bashrc

clear

echo "Done. Metasploit installed: " $INSTALL_PATH
echo "Unstable tree: " $INSTALL_PATH/unstable/
echo "Where to place your personal modules: ~/.msf4/modules/"
echo "Loot Directory: ~/.msf4/loot/"
echo "Log File: ~/.msf4/logs/framework.log"
echo "Ruby version:"
ruby -v
echo "-- Metasploit.com"
