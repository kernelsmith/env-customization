#!/bin/sh
#
# reset (destroy) remote origin and repair using local repo
#

# everything is commented out so no one accidentally nukes their remote
# uncomment only one or the other of the remote add lines depending on whether
# you use ssh or https

# git remote rm origin
# git remote add origin git@github.com:kernelsmith/metasploit-framework.git
# - OR -
# git remote add origin https://github.com/kernelsmith/metasploit-framework.git
# git push -u origin master

echo "If this script did nothing, it's because everything is commented out for safety."
echo "If you really want to do this, you need to edit this script and comment out some lines"

