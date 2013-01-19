#!/bin/bash

for f in `git diff --stat HEAD~2 | grep '\.rb' | grep -v '\.\.\.'| cut -d '|' -f 1 | cut -d ' ' -f 2`; do echo "[*]  Tidying $f" && tools/msftidy.rb "$f";done
