#!/usr/bin/python

# Generate the users guide in output/. Call as
#   usersguide.py <rootsrc>
# where <rootsrc> is the location of the ROOT sources
#
# Axel, 2015-12-04
 
import sys, os, errno, shutil
from glob import glob

from subprocess import check_call

def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc: # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else: raise

def make(rootsrc):
    # Append '/' to the rootsrc prefix if needed.
    if rootsrc and rootsrc[-1] != '/': rootsrc += '/'

    mkdir_p('output')

    invocation = ['make',
                  '-j', '8',
                  '-C', rootsrc + 'documentation/users-guide/' ]

    print('Invoking: ' + ' '.join(invocation))
    check_call(invocation)

    outdir = 'output/'
    shutil.rmtree(outdir, True)
    mkdir_p(outdir)
    for fil in glob(rootsrc + r'documentation/users-guide/output/*'):
        shutil.move(fil, outdir)
    for fil in glob(rootsrc + r'documentation/users-guide/pictures/*'):
        shutil.copy(fil, outdir + 'pictures/')
    for fil in glob(rootsrc + r'documentation/users-guide/css/*'):
        shutil.copy(fil, outdir + 'css/')

if __name__ == '__main__':
    make(sys.argv[1])
