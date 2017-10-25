@echo off

rem Resets the pull request repository to head on requested merging branch
rem First parameter: Cloned ROOT repo location
rem Second parameter: Location of git

cd %1
%2 fetch $GIT_URL +refs/heads/*:refs/remotes/origin/*
%2 checkout -f origin/%ghprbTargetBranch%
