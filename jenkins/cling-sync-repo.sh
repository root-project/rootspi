#!/bin/bash -e

set -x

clingRepo="$WORKSPACE/cling"
rootRepo="$WORKSPACE/root"

export ASKPASSHELPER=$WORKSPACE/credhelper.sh
# Note: this will write '$', 'C', 'L'... into the tool, not the pass!
echo 'echo $CLINGGITPW' > $ASKPASSHELPER
chmod a+x $ASKPASSHELPER

# What was the last commit in root.git's interpreter/cling?
rootCommit=`cd $rootRepo && git rev-list -n 1 HEAD -- interpreter/cling`
if [ "x$rootCommit" = "x" ]; then
  echo 'Cannot extract last cling commit in root repository!' >&2
  exit 1
fi
echo "Most recent commit in ROOT/interpreter/cling: $rootCommit"

# What was the most recent ROOT commit merged into cling?
clingTag=`cd $clingRepo && ( GIT_ASKPASS=$ASKPASSHELPER git ls-remote --tags | grep 'refs/tags/__internal-root-*' | grep -v '\^{}' | tail -n 1 | sed 's,^.*__internal-root-,,' )`
if [ "x$clingTag" = "x" ]; then
  echo 'Cannot extract most recent merge tag!' >&2
  exit 1
fi

if [ "$rootCommit" =  "$clingTag" ]; then
  echo 'cling is already up to date, exiting.'
  exit
fi

startCommit=$clingTag
echo "Applying patches after $startCommit and up to $rootCommit"

patch="$WORKSPACE/root-to-cling-$startCommit-$rootCommit.patch";

# extract the patch
cd $rootRepo
git format-patch --no-stat --find-renames --find-copies --stdout --keep-subject $startCommit..$rootCommit -- interpreter/cling/ > $patch

# For better logs:
cat $patch

# apply the patch
cd $clingRepo
# get rid of previous git-rebase leftovers
git reset --hard origin/master
git rebase --abort || true
git am -p3 $patch
GIT_ASKPASS=$ASKPASSHELPER git push origin HEAD:master
newTag="__internal-root-$rootCommit"
git tag $newTag
GIT_ASKPASS=$ASKPASSHELPER git push origin $newTag
git tag -d __internal-root-$clingTag
GIT_ASKPASS=$ASKPASSHELPER git push origin :refs/tags/__internal-root-$clingTag
# clean up
rm $patch
