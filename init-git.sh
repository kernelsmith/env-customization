#!/bin/sh

# This thing needs work

if [ -z $1 ]; then echo "usage:  $0 dir2init" && exit 1;fi

dir2init="$1"

#Global setup:

git config --global user.name "kernelsmith"
git config --global user.email kernelsmith@kernelsmith.com
# optional
#git config --global user.url "kernelsmith@kernelsmith.com"
        
#Next steps:
# mkdir if nec
if ! [ -d $dir2init ]; then mkdir $dir2init;fi
cd $dir2init

git init
touch README
git add README
git commit -m 'empty readme'
git remote add origin git@github.com:kernelsmith/${dir2init}.git
git push origin master
      
