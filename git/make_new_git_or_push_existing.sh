# It's easiest to first create the repo from your github page

#
# Create a new repository on the command line
#
touch README.md
git init
git add README.md
git commit -m "first commit"
git remote add origin https://github.com/kernelsmith/repo-name.git
git push -u origin master

#
# Push an existing repository from the command line
#
git remote add origin https://github.com/kernelsmith/repo-name.git
git push -u origin master
