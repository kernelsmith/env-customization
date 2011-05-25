#!/bin/sh

apt-get update
# qemu?  terminator if not present already
for pkg in "nvidia-driver smbfs nfs "; do
	apt-get -y install $pkg
done

msfupdate

# get rc files from github?
# vimrc, bashrc

# install private key?

