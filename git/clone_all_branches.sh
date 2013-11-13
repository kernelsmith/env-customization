#!/bin/sh

# This script tries to be posix compliant, so no bash'isms
# This script assumes you have an existing repo, the dir for which is your pwd, such as one created with
# git clone https://github.com/kernelsmith/metasploit-framework.git
# The script will create a local branch for each remote branch (origin only) and update the local branch to match the remote

# Usage:
# $0 [-d] [-f grep_filter]
# -d dryrun,just shows you what would happen but doesn't do anything
# -f filter, filter is applied to branches to be cloned via a grep

# function declarations
puts() {
	echo "[*]  $1"
}

# do the damn thing
me="$0"
dryrun=
filter=
filter_arg=
while getopts df: name; do
	case $name in
		d)	dryrun="true";;
		f)	filter="true"
				filter_arg="$OPTARG";;
		?)	puts "Usage:  $me [-d] [-f grep_filter]"
				exit 2;; 
	esac
done
echo
puts "Doing some housekeeping first..."
puts " - Garbage collecting..."
git gc --prune=now
puts " - Pruning remote origin..."
git remote prune origin
branches_to_add=$(git branch -r | grep origin | grep -v msdn_|grep -v 'HEAD\|master')
if [ -n "$filter" ]; then branches_to_add=$(echo $branches_to_add | grep $filter_arg);fi
for branch in $branches_to_add; do
	local_branch=$(echo $branch | cut -d "/" -f 2-)
	puts "Creating local branch:$local_branch and downloading:$branch"
	if [ -n "$dryrun" ];then
		echo git checkout -b $local_branch $branch
	else
		git checkout -b $local_branch $branch # create (and checkout) local branch and download remote branch "into" it
	fi
done
git checkout master
puts "Done."
echo
