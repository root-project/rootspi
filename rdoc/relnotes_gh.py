#!/usr/bin/python

# Generate the release notes in release-notes.html. Call as
#   relnotes.py <rootsrc> master
# or
#   relnotes.py <rootsrc> v6-06-00-patches
# where <rootsrc> is the location of the ROOT sources
#
# Axel, 2015-11-26

import sys, os, errno
from glob import glob
import shutil
from subprocess import check_call

def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc: # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else: raise

def make(rootsrc, branch):
    # Append '/' to the rootsrc prefix if needed.
    if rootsrc and rootsrc[-1] != '/': rootsrc += '/'

    # Determine the subdirectory of README/ReleaseNotes/ to use
    versionDir = branch.replace('-00-patches', '').replace('-', '')
    if versionDir == 'master':
        # Take the one with the highest number:
        mdDir = sorted(glob(rootsrc + 'README/ReleaseNotes/v*/'))[-1]
    else:
        mdDir = rootsrc + 'README/ReleaseNotes/' + versionDir + '/'

    mkdir_p(versionDir)

    invocation = ['pandoc',
                  '-f', 'markdown',
                  '-t', 'html',
# Filter fails since last pandoc upgrade:
# Error in $.block[0].c[0][0].c[0].c: cannot unpack array of length 2 into a tuple of length 3
#                  '--filter', rootsrc + 'build/unix/pandoc-jira.sh',
# Disable the filter...
                  '-s',
                  '-f', 'markdown+smart',
                  '--toc',
                  '-H', rootsrc + 'documentation/users-guide/css/github.css',
                  '--mathjax',
                  mdDir + 'index.md',
                  '-o', versionDir+'/release-notes.html']

    print('Invoking: ' + ' '.join(invocation))
    check_call(invocation)
    shutil.copytree(mdDir, versionDir, ignore=shutil.ignore_patterns("index.md"), dirs_exist_ok=True)

if __name__ == '__main__':
    # test1.py executed as script
    # do something
    make(sys.argv[1], sys.argv[2])
