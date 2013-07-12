alias ll='ls -lah'
alias sudi='sudo -i'
alias suck='sudo -u ks'
alias xclip='xclip -sel clip'

function rgrep() { 
	if [ -n "${2}" ]; then 
		find -L . -type f -name \*.*rb -exec grep -n -C $2 -i -H --color "$1" {} \; 
	else
		find -L . -type f -name \*.*rb -exec grep -n -i -H --color "$1" {} \;
	fi
}

# shorten github urls
function shorten() {
	curl -s -S -i http://git.io -F "url=$1" | grep Location | cut -d " " -f 2
}

function up {
	if [ -d ".svn" ]; then
		svn up --ignore-externals $@
	else
		stash=$(git stash save)
		git fetch origin
		git pull -r $@
		[ "$stash" != "No local changes to save" ] && git stash pop
	fi
	date
}; export -f up
