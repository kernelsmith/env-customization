#!/bin/bash

MOUNT_POINT="/Volumes/sshfs"                        # like /Volumes/sshfs or /mnt/sshfs
REMOTE_PATH_TO_MOUNT="/vmfs/volumes/datastore_RAID" # like /vmfs/volumes/datastore1
PATH_TO_SSHFS="sshfs"                               # just use "sshfs" if it's in root's path
SSH_USER="root"                                     # usually root for an esxi server unless you changed stuff
SSH_SERVER="esxi"                                   # IP or hostname of esxi server
LOCAL_USER_ID=501                                   # The UID of the local user to map to remote user
LOCAL_GROUP_ID=20                                   # The GID of the local group to map to remote group
                                                    # The UID/GID help avoid permissions/ownership issues

# mkdir if nec
if ! [ -d "$MOUNT_POINT" ]; then
	sudo mkdir -p "$MOUNT_POINT"
fi

sudo $PATH_TO_SSHFS ${SSH_USER}@${SSH_SERVER}:${REMOTE_PATH_TO_MOUNT} $MOUNT_POINT -o idmap=user -o allow_other -o uid=$LOCAL_USER_ID -o gid=$LOCAL_GROUP_IDi -o no_readadhead -o noappledouble -o nolocalcaches
# sshfs username@hostname:remote_path local_mount_point -o idmap=user -o allow_other -o uid=1001 -o gid=1001
# idmap=user,uid=501,no_readahead,noappledouble,nolocalcaches
