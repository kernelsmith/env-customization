alias ll='ls -lah'
alias sudi='sudo -i'
alias suck='sudo -u ks'
function rgrep() { 
        if [ -n "${2}" ]; then 
                find -L . -type f -name \*.*rb -exec grep -n -C $2 -i -H --color "$1" {} \; 
        else
                find -L . -type f -name \*.*rb -exec grep -n -i -H --color "$1" {} \;
        fi
}
