#!/bin/bash
#
# Copy all User's Guide build products to the html directory.
# This script is called with the following arguments:
#   copyug.sh <where user's guide is generated> <htmlxxx/users-guide>
# e.g.:
#   copyug.sh $srcdir/documentation/users-guide $docdir

prog=`basename $0`
if [ $# -ne 2 ]; then
   echo "$prog: src and dest arguments need to be specified"
   exit 1
fi

src=$1

dest=$2
destpic=$dest/pictures
destchap=$dest/ROOTUsersGuideChapters

if [ ! -d $destpic ]; then
   mkdir -p $destpic
fi

if [ ! -d $destchap ]; then
   mkdir -p $destchap
fi

cp $src/pictures/*                 $destpic/

fullguides="
ROOTUsersGuideA4.pdf
ROOTUsersGuideLetter.pdf
ROOTUsersGuide.html
ROOTUsersGuide.epub
"

chapters="
Introduction
GettingStarted
Histograms
Graphs
FittingHistograms
ALittleC++
CINT
ObjectOwnership
Graphics
FoldersTasks
InputOutput
Trees
MathLibraries
LinearAlgebra
AddingaClass
CollectionClasses
PhysicsVectors
Geometry
PythonRuby
TutorialsandTests
ExampleAnalysis
Networking
Threads
PROOF
WritingGUI
ROOTandQt
HTMLDoc
InstallandBuild
"

for f in $fullguides; do
   cp $src/$f $dest
done

for c in $chapters; do
   cp $src/$c.html $dest
done

for c in $chapters; do
   cp $src/$c.pdf $destchap
done

exit 0
