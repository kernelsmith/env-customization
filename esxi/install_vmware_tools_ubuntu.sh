#!/bin/sh

# you must mount the vmware tools iso by right-clicking the host in viclient, goto guest, install/upgrade vmware tools
# you'll see it in dmesg when you do, try dmesg | sr0

MOUNT_POINT="/media/cdrom"
CDROM_DEVICE="/dev/cdrom"
UNZIP_DIR="/tmp"

mkdir_if_nec() {
  if ! [ -d "$1" ]; then
    sudo mkdir -p "$1"
  fi
}

inform() {
  echo "[*] $@"
}

inform "Updating packages"
sudo apt-get update > /dev/null
sudo apt-get -y upgrade

inform "Creating mount point ($MOUNT_POINT) if necessary"
mkdir_if_nec "$MOUNT_POINT"

inform "Mounting the vmware tools ISO, you will likely see a write-protected/read-only message"
sudo mount "$CDROM_DEVICE" "$MOUNT_POINT"

# You should see a message similar to: mount: block device /dev/sr0 is write-protected, mounting read-only

inform "Creating unzip dir ($UNZIP_DIR) if nec"
mkdir_if_nec "$UNZIP_DIR"
cd "$UNZIP_DIR"

inform "Copying installer to unzip dir ($UNZIP_DIR)"
sudo cp "$MOUNT_POINT"/VM*.tar.gz .

inform "Installing build tools as necessary"
sudo apt-get -y install gcc linux-headers-server build-essential

inform "Unmounting $MOUNT_POINT"
sudo umount "$MOUNT_POINT"
# you could also remove the $MOUNT_POINT if you wanted, but we don't presume

inform "Decompressing installer"
sudo tar xzf VM*.tar.gz
cd vmware-tools-dist*

# To prevent the potential error below, on Ubuntu 11.10+, create a special directory
# 'Unable to create symlink “/usr/lib64/libvmcf.so” pointing to file "/usr/lib/vmware-tools/lib64/libvmcf.so/libvmcf.so"'
inform "Creating lib64 dir (/usr/lib64) if nec"
mkdir_if_nec "/usr/lib64"

# Run the Install Script. The -d flag automatically answers the default to all questions. To customize it, just omit the -d.
inform "Starting installer using default options"
sudo ./vmware-install.pl -d

inform "***************************************************** [*]"
inform "                                                      [*]"
inform "                 !!! WARNING! !!!                     [*]"
inform "                                                      [*]"
inform "   REBOOTING in 5 seconds unless you ctl-C to quit    [*]"
inform "                                                      [*]"
inform "                 !!! WARNING! !!!                     [*]"
inform "                                                      [*]"
inform "***************************************************** [*]"
sleep 5 && sudo reboot
