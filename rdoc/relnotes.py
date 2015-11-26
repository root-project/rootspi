#!/usr/bin/python

# Generate the release notes in release-notes.html. Call as
#   relnotes.py master
# or
#   relnotes.py v6-06-00-patches
#
# Axel, 2015-11-26
 
import sys
from glob import glob
from subprocess import check_call

branch = sys.argv[1]
versionDir = branch.replace('-00-patches', '').replace('-', '')
if versionDir == 'master':
    # Take the one with the highest number:
    print glob('README/ReleaseNotes/v*/').sort()
    mdDir = sorted(glob('README/ReleaseNotes/v*/'))[-1]
else:
    mdDir = 'README/ReleaseNotes/' + versionDir + '/'

invocation = ['pandoc',
      '-f', 'markdown',
      '-t', 'html',
      '-s', '-S',
      '-f', 'markdown',
      '--toc',
      '-H', 'documentation/users-guide/css/github.css',
      '--mathjax',
      mdDir + 'index.md',
      '-o', 'release-notes.html']

print('Invoking: ' + ' '.join(invocation))
check_call(invocation)
