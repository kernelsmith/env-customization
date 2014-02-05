#!/bin/bash

MOUNT_POINT="${HOME}/sshfs"                        # like /Volumes/sshfs or /mnt/sshfs
#REMOTE_PATH_TO_MOUNT="/vmfs/volumes/datastore_RAID" # like /vmfs/volumes/datastore1
REMOTE_PATH_TO_MOUNT="/var/www/production"
PATH_TO_SSHFS="sshfs"                               # just use "sshfs" if it's in root's path
SSH_USER="zdi"                                     # usually root for an esxi server unless you changed stuff
SSH_SERVER="redmine"                                   # IP or hostname of esxi server
LOCAL_USER_ID=501                                   # The UID of the local user to map to remote user
LOCAL_GROUP_ID=20                                   # The GID of the local group to map to remote group
                                                    # The UID/GID help avoid permissions/ownership issues
SSH_KEY="/Users/kernelsmith/.ssh/zdi_rsa"
OTHER_SSH_OPTIONS="allow_other no_readahead noappledouble nolocalcaches StrictHostKeyChecking=no"
SSHFS_DEBUG_OPTIONS="debug,sshfs_debug,loglevel=debug"

# mkdir if nec
if ! [ -d "$MOUNT_POINT" ]; then
	mkdir -p "$MOUNT_POINT" && echo "[*] Created $MOUNT_POINT"
fi

echo "[*] Unless you have passwordless sudo or have sudo'ed recently, the first "
echo "[*] password request is for sudo, the second is for the ssh server, unless you are using keys"

command="$PATH_TO_SSHFS ${SSH_USER}@${SSH_SERVER}:${REMOTE_PATH_TO_MOUNT} $MOUNT_POINT"
# add ssh key identity if given
if [ -n "$SSH_KEY" ]; then command="$command -o IdentityFile=$SSH_KEY";fi
# add local user id option if given
if [ -n "$LOCAL_USER_ID" ]; then command="$command -o idmap=user -o uid=$LOCAL_USER_ID";fi
# add local group id option if given (this isn't supported by all implementations)
if [ -n "$LOCAL_GROUP_ID" ]; then command="$command -o gid=$LOCAL_GROUP_ID";fi
# add all the 'other' options
if [ -n "$OTHER_SSH_OPTIONS" ]; then
  for opt in $OTHER_SSH_OPTIONS; do
    command="$command -o $opt";
  done
fi
# add sshfs debug options if given
if [ -n "$SSHFS_DEBUG_OPTIONS" ]; then command="$command -o $SSHFS_DEBUG_OPTIONS";fi
echo "[*] Running the following command:"
echo "sudo $command"
sudo $command
# sshfs username@hostname:remote_path local_mount_point -o idmap=user -o allow_other -o uid=1001 -o gid=1001
# idmap=user,uid=501,no_readahead,noappledouble,nolocalcaches
