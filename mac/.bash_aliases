# some ls aliases
alias ll='ls -alh'
alias la='ls -A'
alias l='ls -CF'

# some sudo aliases
alias sudi='sudo -i'
alias suck='sudo -u ks'

# some functions
function rgrep() { 
        if [ -n "${2}" ]; then 
                find -L . -type f -name \*.*rb -exec grep -n -C $2 -i -H --color "$1" {} \; 
        else
                find -L . -type f -name \*.*rb -exec grep -n -i -H --color "$1" {} \;
        fi
}
# git branch is also defined in bashrc for clarity it's also here
function git_branch {
	git branch --no-color 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
