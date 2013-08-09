#!/bin/sh

# function declarations
puts() {
	echo "[*]  $1"
}

puts ""
git checkout master # just to be safe
if ! git branch -a | grep -q 'remotes/upstream/master'; then
	# add the rapid7 repo as a remote branch and call it "upstream"
	# we're using the https version here because ssh is blocked where I work
	puts "Did not find upstream branch, so adding it..."
	git remote add upstream https://github.com/rapid7/metasploit-framework.git
	# git remote add upstream git://github.com/rapid7/metasploit-framework.git
fi
puts "Downloading updates..."
git fetch upstream/master # download objects from upstream's master to holding area (.git/FETCH_HEAD)
puts "Rebasing your local master branch with downloaded updates..."
git rebase upstream/master # rebase against your local master (you better be on your master branch?)
puts "Done."
puts ""
