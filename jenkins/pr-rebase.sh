#!/bin/bash

# Resets the pull request repository to head of source branch,
# then rebases it on top of the target branch
# First parameter: Cloned ROOT repo location
# Second parameter: Location of git

cd $1
$2 checkout -f origin/pr/$ghprbPullId/head
$2 rebase -v -f origin/$ghprbTargetBranch
