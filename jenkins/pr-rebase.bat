@echo off

rem Resets the pull request repository to head of source branch,
rem then rebases it on top of the target branch
rem First parameter: Cloned ROOT repo location
rem Second parameter: Location of git

cd %1
%2 checkout -f origin/pr/%ghprbPullId%/head
%2 rebase -f -v origin/%ghprbTargetBranch%
