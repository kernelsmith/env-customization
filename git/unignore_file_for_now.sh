#!/bin/bash

file="$1"

# So, to temporarily ignore changes in a certain file, run:
#git update-index --assume-unchanged $file
# Then when you want to track changes again:
git update-index --no-assume-unchanged $file
