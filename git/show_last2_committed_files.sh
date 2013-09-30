#!/bin/bash

git diff --stat HEAD~2

# show differences between index and working tree
# that is, changes you haven't staged to commit
# git diff [filename]
# show differences between current commit and index
# that is, what you're about to commit
# git diff --cached [filename]
# show differences between current commit and working tree
# git diff HEAD [filename]
