#!/bin/bash -e

set -x

# arg1 defines the mode of operation.
#  clean: remove repos
#  fromscratch: clean, then build

function clean {
  # remove checked-out repos
  rm -rf root
  rm -rf cling
}

mode="x$1"

case $mode  in
  xclean)
    clean
    exit
    ;;
  xfromscratch)
    clean
    ;;
  x)
    ;;
  *)
    echo 'Invocation error! Passed '$1' but expected one of "", "clean", "fromscratch".' >&2
    ;;    
esac

if [ "$mode" = "xclean" ]; then
  clean
  exit
fi

[ "$mode" = "xfromscratch" ] && clean

# Clone / update cling
[ -d cling ] || git clone http://root.cern.ch/git/cling.git
cd cling
git pull
git reset --hard
cd ..

# What was the last commit in root.git's interpreter/cling?
rootCommit=`cd root&& git rev-list -n 1 HEAD -- interpreter/cling`
if [ "x$rootCommit" = "x" ]; then
  echo 'Cannot extract last cling commit in root repository!' >&2
  exit
fi
echo "Most recent commit in ROOT/interpreter/cling: $rootCommit"

# What was the most recent ROOT commit merged into cling?
clingTag=`cd cling && git tag -l '__internal-root-*'`
if [ "x$clingTag" = "x" ]; then
  echo 'Cannot extract most recent merge tag!' >&2
  exit
fi

if [ "__internal-root-$rootCommit" =  "$clingTag" ]; then
  echo 'cling is already up to date, exiting.'
  exit
fi

startCommit="${clingTag/__internal-root-/}"
echo "Applying patches after $startCommit and up to $rootCommit"

patch="root-to-cling-$startCommit-$rootCommit.patch";

# extract the patch
cd root
git format-patch --no-stat --find-renames --find-copies --stdout --keep-subject $startCommit..$rootCommit -- interpreter/cling/ > ../$patch

# For better logs:
cd ..
cat $patch

# apply the patch
cd cling
git am -p3 ../$patch
git push
newTag="__internal-root-$rootCommit"
git tag $newTag
git push origin $newTag
git tag -d $clingTag
git push origin :refs/tags/$clingTag

# clean up
cd ..
rm $patch
