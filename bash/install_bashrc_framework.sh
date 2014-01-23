#!/bin/bash

backup() {
  # $@ are files to be backed up
  for file in $@; do
    mv "$file" "${file}.bkp"
  done
}

# check that we are in a git repo (preferably the right one)
# also save the directory for use later
if grep -q BASHRC_COMPLETE "./.bashrc" 2> /dev/null; then
  # then we are probably in the right place
  source_dir=$(pwd)
else
  echo "You don't seem to be running this installer from the downloaded bash directory."
  echo "Try cd'ing to the 'bash' dir inside the downloaded bashrc framework."
  exit 128
fi

home_files_to_backup="${HOME}/.bash_profile ${HOME}/.bashrc ${HOME}/.vimrc"
backup home_files_to_backup

# softlink to the framework files
ln -s ${HOME}/.bash_profile ${source_dir}/.bash_profile
ln -s ${HOME}/.bashrc ${source_dir}/.bashrc
ln -s ${HOME}/load_drop_directories.rc ${source_dir}/load_drop_directories.rc
ln -s ${HOME}/.vimrc ${source_dir}/.bashrc
# and directories
for dropdir in $(ls ${source_dir}/*.d); do
  ln -s ${HOME}/$dropdir ${source_dir}/$dropdir
done
mkdir ${HOME}/private.d # for your secret sauce, it will get loaded automatically
# put stuff in private.d, and don't forget to chmod them
chmod -R +ox ${HOME}/private.d # or whatever