# Copy binaries from https://root.cern to CVMFS.
# Based on a bash script by Bertrand and Patricia, 2015-2016.
# Axel, 2018-11-13

# MUST BE RUN AS USER cvsft!

import atexit
import os
import re
import shutil
import subprocess
from io import BytesIO
import tarfile
import traceback
from urllib.request import urlopen

def check_basedir(basedir):
    '''
    Check that the cvmfs dir exists.
    '''
    if not os.path.exists(basedir):
        raise FileNotFoundError('Directory ' + basedir + ' does not exist!')
    if not os.path.isdir(basedir):
        raise NotADirectoryError(basedir + ' is not a directory!')

def check_version():
    '''
    Check that $VERSION exists and return it.
    '''
    version = os.environ['VERSION']
    if not version:
        raise AssertionError('Must have $VERSION set!')
    return version

def check_replace():
    '''
    Check that $REPLACE exists and return whether it's "true" or "True" or "1".
    '''
    replace = os.environ['REPLACE']
    if not replace:
        raise AssertionError('Must have $REPLACE set!')
    return replace.lower() == "true" or replace == "1"

def parse_files_to_extract(baseurl, version):
    '''
    Parse the files to download and extract, as available from
    ROOT's downloads page.
    '''
    website = urlopen(baseurl)
    html = website.read()
    files = re.findall(b'<a href="(root_v' + version.encode('ascii') + b'.[^"]+)"', html)
    files = sorted(set(files))
    # filter out Windows; keep only tar.gz
    files = [f.decode('ascii') for f in files if not b'.win' in f and b'.tar.gz' in f]
    return files

def cvmfs_abort_transaction():
    '''
    Abort the ongoing cvmfs transaction (the error case).
    '''
    returncode = subprocess.call(['cvmfs_server', 'abort', '-f', 'sft.cern.ch'])
    if returncode != 0:
        RuntimeError('CVMFS repository "sft.cern.ch" failed to abort transaction!')

def cvmfs_publish_transaction():
    '''
    Close and publish the ongoing cvmfs transaction (the success case).
    '''
    os.chdir(os.environ['HOME'])
    atexit.unregister(cvmfs_abort_transaction)

    returncode = subprocess.call(['cvmfs_server', 'publish', 'sft.cern.ch'])
    if returncode != 0:
        RuntimeError('CVMFS repository "sft.cern.ch" failed to publish the transaction!')

def cvmfs_open_transaction(basedir):
    '''
    Open a cvmfs transaction; add an atexit handler to close it.
    '''
    returncode = subprocess.call(['cvmfs_server', 'transaction', 'sft.cern.ch'])
    if returncode != 0:
        RuntimeError('CVMFS repository "sft.cern.ch" is locked!')

    atexit.register(cvmfs_abort_transaction)

def prepare_version_dir(basedir, version, replace):
    '''
    Create (or re-create, if replace is True) the "output" directory
    for the given ROOT version.
    '''
    versiondir = os.path.join(basedir, version)
    if replace and os.path.exists(versiondir):
        shutil.rmtree(versiondir)
    os.mkdir(versiondir)
    os.chdir(versiondir)

def get_cvmfs_dirname(filename, version):
    '''
    Given the filename as stated on the ROOT download page,
    determine the corresponding directory name for cvmfs:

      root_v6.14.04.source.tar.gz => src
      root_v6.14.04.Linux-fedora27-x86_64-gcc7.2.tar.gz => x86_64-fedora27-gcc72-opt
      root_v6.14.04.macosx64-10.13-clang91.tar.gz => x86_64-mac1013-clang91-opt

    No Windows gets published into cvmfs.
    '''
    # matches:
    # ('Linux', '-Raspbian9.4arm6l-gcc6.3', None, 'tar.gz')
    # ('macosx64', '-10.12-clang90', None, 'dmg')
    # ('source', None, None, 'tar.gz')
    matches = re.match('^root_v' + version + '[.](Linux|macosx64|source)(-[^-]+)?(-[^-]+)?(-[^-]+)?[.]tar[.]gz$', filename)
    if not matches:
        raise RuntimeError('Ignoring unknown file name syntax / extension ' + filename)
    print(matches.groups())
    if matches.group(1) == 'source':
        # ('source', None, None, None)
        return 'src'
    elif matches.group(1) == 'macosx64':
        # ('macosx64', '-10.13', '-clang91', None)
        # x86_64-mac1013-clang91-opt
        macvers = matches.group(2)[1:].replace('.','') # 1013
        return 'x86_64-mac' + macvers + matches.group(3) + '-opt'
    elif matches.group(1) == 'Linux':
        if matches.group(3) == '-x86_64':
            # ('Linux', '-ubuntu18', '-x86_64', '-gcc7.3')
            # x86_64-ubuntu18-gcc73-opt
            compvers = matches.group(4).replace('.', '')
            return 'x86_64' + matches.group(2).lower() + compvers + '-opt'
        else:
            # ('Linux', '-Raspbian9.4arm6l', '-gcc6.3', None)
            # x86_64-raspbian9.4arm6l-gcc63-opt
            compvers = matches.group(3).replace('.', '')
            return matches.group(2).lower()[1:] + compvers + '-opt'
    raise RuntimeError('Ignoring unknown platform in file ' + filename)

def download_and_extract_tar(baseurl, filename, platformdir):
    '''
    Download the filename from baseurl, extract it, renaming its top-level
    directory as platformdir
    '''
    response = urlopen(baseurl + filename)
    rawTarGz = response.read()
    tar = tarfile.open(mode='r:gz', fileobj = BytesIO(rawTarGz))
    tartopdir = tar.getmembers()[0].name
    tar.extractall()
    os.rename(tartopdir, platformdir)

def install_to_cvmfs(basedir, baseurl):
    check_basedir(basedir)
    version = check_version()
    replace = check_replace()
    files = parse_files_to_extract(baseurl=baseurl, version=version)
    cvmfs_open_transaction(basedir=basedir)
    prepare_version_dir(basedir=basedir, version=version, replace=replace)
    for filename in files:
        try:
            platformdir = get_cvmfs_dirname(filename=filename, version=version)
        except RuntimeError:
            print(traceback.format_exc())
            continue
        download_and_extract_tar(baseurl=baseurl, filename=filename, platformdir=platformdir)
    cvmfs_publish_transaction()


basedir = '/cvmfs/sft.cern.ch/lcg/app/releases/ROOT'
baseurl = 'http://root.cern/download/'

install_to_cvmfs(basedir=basedir, baseurl=baseurl)
