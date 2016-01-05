# Build cling in Jenkins.
#
# Triggered by SCM: incremental build.
# Triggered by schedule: full build.
# Manual trigger: parametrized.
#
# Parameters == env vars:
# - CLEAN:
# remove build and install directories. Default for full builds.
# - BINARIES:
# whether to publish binaries, source snapshot and doxygen documentation to
# root.cern.ch
# - TESTCLING:
# whether to run cling's test suite (and fail if it fails)
# - TESTLLVMCLANG:
# whether to run llvm's and clang's test suite. clang's test suite is known to
# fail; clang's test result is thus ignored in the outcome of this step. A
# failure in llvm's test suite will fail the build, though.
# - LABEL:
# 'ubuntu14' is expected to be able to run doxygen and will create source
# snapshot if binaries are requested.
#
# Axel, 2016-01-05

import sys, os, errno, shutil, tarfile
from subprocess import check_call, call
from datetime import date


def mkdir_p(path):
    try:
        os.makedirs(path)
    except OSError as exc: # Python >2.5
        if exc.errno == errno.EEXIST and os.path.isdir(path):
            pass
        else: raise

def print_and_call(args, check=True):
    print('Running: ' + str(args))
    sys.stdout.flush()
    if check:
        check_call(args=str(args), shell=True)
    else:
        call(args=str(args), shell=True)


class Builder:
    """Build cling"""

    def printConfig(self):
        print('CONFIGURATION: ' + str(dict(self)))


    def cmake_build(self, targetname = '', check = True):
        target = ''
        if targetname:
            target = '--target ' + target
        print_and_call('cmake --build . ' + target + self.parallelFlag, check = check)


    def __init__(self, workspace, label, generatorType, cleanbuild, binaries, buildcause, testcling, testllvmclang):
        self.today = str(date.today())
        self.workspace = workspace
        self.label = label
        self.generatorType = generatorType
        self.testcling = testcling
        self.testllvmclang = testllvmclang

        self.parallelFlag = ''
        if generatorType == 'Unix Makefiles':
            self.parallelFlag = ' -- -j8'


        # Build setup (manual, nightly, incremental)
        if buildcause != 'MANUALTRIGGER':
            # nightly wins, even if there was a commit right before.
            if 'TIMERTRIGGER' in buildcause:
                # nightly build
                binaries = True
                cleanbuild = True
            elif 'SCMTRIGGER' in buildcause:
                # incremental build
                binaries = False
                cleanbuild = False

        self.instdir = 'inst'
        if binaries:
            self.instdir = 'cling_' + today + '_' + label
            cleanbuild = True

        if not os.path.isdir('obj'):
            # force configure
            cleanbuild = True

        self.cleanbuild = cleanbuild
        self.binaries = binaries

        self.printConfig()


    def maybe_clean(self):
        if self.cleanbuild:
            if os.path.isdir(self.instdir):
                shutil.rmtree(self.instdir)
            if os.path.isdir('obj'):
                shutil.rmtree('obj')


    def configure(self):
        mkdir_p('obj')
        if self.cleanbuild:
            print_and_call('cmake ../src -G "' + self.generatorType + '"'
                           + ' -DCMAKE_BUILD_TYPE=Release'
                           + ' -DCMAKE_INSTALL_PREFIX=' + self.workspace + '/' + self.instdir
                           + ' "-DLLVM_LIT_ARGS=-sv --no-progress-bar --xunit-xml-output=lit-xunit-output.xml"'
                           + ' -DLLVM_ENABLE_DOXYGEN=On')


    def make(self):
        self.cmake_build()
        self.cmake_build('install')


    def maybe_test(self):
        if self.testcling:
            self.cmake_build('cling-test')

        if self.testllvmclang:
            self.cmake_build('check-llvm')
            # NO check_call - clang's test suite is known to fail with cling patches!
            self.cmake_build('clang-test', check=False)


    def documentation(self):
        if self.label == 'ubuntu14':
            self.cmake_build('doxygen-cling')


    def packaging(self):
        if os.path.isdir('artifacts'):
            shutil.rmtree('artifacts') # remove old files, no need to re-copy
        mkdir_p('artifacts') # needed for scp step, even if empty

        if self.binaries:
            tar = tarfile.open(os.path.join('artifacts', instdir + '.tar.bz2'), "w:bz2")
            tar.add(self.instdir)
            tar.close()
            if self.label == 'ubuntu14':
                tar = tarfile.open(os.path.join('artifacts', 'cling_' + self.today + '_sources.tar.bz2'), "w:bz2")
                tar.add('src')
                tar.close()

    def build(self):
        print('STEP: CLEAN')
        self.maybe_clean()
        os.chdir('obj')
        print('STEP: CONFIGURE')
        self.configure()
        print('STEP: MAKE')
        self.make()
        print('STEP: TEST')
        self.maybe_test()
        print('STEP: DOCUMENTATION')
        self.documentation()
        os.chdir(workspace)
        print('STEP: PACKAGING')
        self.packaging()


