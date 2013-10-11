#!/bin/bash

MOUNT_POINT="/Volumes/sshfs"                        # like /Volumes/sshfs or /mnt/sshfs
REMOTE_PATH_TO_MOUNT="/vmfs/volumes/datastore_RAID" # like /vmfs/volumes/datastore1
PATH_TO_SSHFS="sshfs"                               # just use "sshfs" if it's in root's path
SSH_USER="root"                                     # usually root for an esxi server unless you changed stuff
SSH_SERVER="esxi"                                   # IP or hostname of esxi server

# mkdir if nec
if ! [ -d "$MOUNT_POINT" ]; then
  echo "Creating directory for mountpoint"
	sudo mkdir -p "$MOUNT_POINT"
fi
cmd="sudo $PATH_TO_SSHFS ${SSH_USER}@${SSH_SERVER}:${REMOTE_PATH_TO_MOUNT} $MOUNT_POINT"
# sshfs user@hostname:path mount_point
echo "Running:  $cmd"
echo "First password is the local sudo password, second is the password for ${SSH_USER}@${SSH_SERVER}"
$cmd
