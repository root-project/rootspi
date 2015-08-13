import os
import errno
import subprocess
import tarfile

def cmake(*args):
    # Raise if unhappy!
    subprocess.check_call(['cmake'] + list(args))

# cd into the build directory
def MakeIfNeeded(dir):
    try:
        os.makedirs(dir)
    except OSError as exception:
        if exception.errno != errno.EEXIST:
            raise

MakeIfNeeded('obj')
pwd = os.getcwd()
instdir = pwd[:-3] + 'inst'
cmake('../src', '-DCMAKE_INSTALL_PREFIX=' + instdir)
cmake('--build', '.')
os.cd('..')

MakeIfNeeded('artifacts')
os.cd('inst')

gitcommit = os.environ['GIT_COMMIT']
tarfilename = '../artifacts/cling_' + gitcommit + '.tar.bz2'
with tarfile.open(tarfilename, 'w:bz2') as tar:
    tar.add('.') # and recursively so.
