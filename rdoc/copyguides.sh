#!/bin/bash
#
# Copy different guide build products to the html directory.
# This script is called with the following arguments:
#   copyguides.sh <where user's guide is generated> <htmlxxx/guides/users-guide>
# e.g.:
#   copyguides.sh $srcdir $docdir

prog=`basename $0`
if [ $# -ne 2 ]; then
   echo "$prog: src and dest arguments need to be specified"
   exit 1
fi

src=$1
dest=$2

# User's Guide products
srcug=$src/documentation/users-guide/output
destug=$dest/users-guide
destugpic=$destug/pictures
destugchap=$destug/ROOTUsersGuideChapters

if [ ! -d $destug ]; then
   mkdir -p $destug
fi

if [ ! -d $destugpic ]; then
   mkdir -p $destugpic
fi

if [ ! -d $destugchap ]; then
   mkdir -p $destugchap
fi

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
Cling
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

cp $srcug/../pictures/*        $destugpic/

for f in $fullguides; do
   cp $srcug/$f $destug
done

for c in $chapters; do
   cp $srcug/$c.html $destug
done

for c in $chapters; do
   cp $srcug/$c.pdf $destugchap
done

# Minuit2 products
srcmin2=$src/documentation/minuit2
destmin2=$dest/minuit2
destmin2fig=$destmin2/figures

if [ ! -d $destmin2 ]; then
   mkdir -p $destmin2
fi

if [ ! -d $destmin2fig ]; then
   mkdir -p $destmin2fig
fi

min2guides="
Minuit2.pdf
Minuit2Letter.pdf
Minuit2.html
Minuit2.epub
"

cp $srcmin2/figures/*        $destmin2fig/

for f in $min2guides; do
   cp $srcmin2/$f $destmin2
done

# Spectrum products
srcspec=$src/documentation/spectrum
destspec=$dest/spectrum
destspecfig=$destspec/figures

if [ ! -d $destspec ]; then
   mkdir -p $destspec
fi

if [ ! -d $destspecfig ]; then
   mkdir -p $destspecfig
fi

specguides="
Spectrum.pdf
SpectrumLetter.pdf
Spectrum.html
Spectrum.epub
"

cp $srcspec/figures/*        $destspecfig/

for f in $specguides; do
   cp $srcspec/$f $destspec
done

# HttpServer products
srchttp=$src/documentation/HttpServer
desthttp=$dest/HttpServer
desthttpfig=$desthttp/figures

if [ ! -d $desthttp ]; then
   mkdir -p $desthttp
fi

if [ ! -d $desthttpfig ]; then
   mkdir -p $desthttpfig
fi

httpguides="
HttpServer.pdf
HttpServerLetter.pdf
HttpServer.html
HttpServer.epub
"

cp $srchttp/figures/*        $desthttpfig/

for f in $httpguides; do
   cp $srchttp/$f $desthttp
done

# JSROOT products
srchttp=$src/documentation/JSROOT
desthttp=$dest/JSROOT
desthttpfig=$desthttp/figures

if [ ! -d $desthttp ]; then
   mkdir -p $desthttp
fi

if [ ! -d $desthttpfig ]; then
   mkdir -p $desthttpfig
fi

httpguides="
JSROOT.pdf
JSROOTLetter.pdf
JSROOT.html
JSROOT.epub
"

cp $srchttp/figures/*        $desthttpfig/

for f in $httpguides; do
   cp $srchttp/$f $desthttp
done

# TMVA products
srctmva=$src/documentation/tmva/UsersGuide
desttmva=$dest/tmva

if [ ! -d $desttmva ]; then
   mkdir -p $desttmva
fi

tmvaguides="
TMVAUsersGuide.pdf
"

for f in $tmvaguides; do
   cp $srctmva/$f $desttmva
done


# Copy the guides to root.cern.ch
echo "Synchronize $dest/ with root.cern.ch:/var/www/root/root/$dest/"
rsync --delete -a $dest/ root.cern.ch:/var/www/root/root/$dest/

exit 0
