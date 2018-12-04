#---Common Setting----------------------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/rootCommon.cmake)

cmake_policy(SET CMP0057 NEW) # interpret the IN_LIST operator
cmake_policy(SET CMP0061 NEW) # do not pass "-i" to GNU make ("continue on error as if success")

#
#  Initialize ${all_modules} to all available build options.
#
function(GET_ALL_MODULES)
  execute_process(
    COMMAND git grep "^ROOT_BUILD_OPTION" cmake/modules/RootBuildOptions.cmake
    WORKING_DIRECTORY "${CTEST_SOURCE_DIRECTORY}"
    OUTPUT_VARIABLE GITGREP
  )
  if(NOT GITGREP)
  message(FATAL_ERROR "Cannot get configuration options from ${CTEST_SOURCE_DIRECTORY}/cmake/modules/RootBuildOptions.cmake")
  endif()
  string(REGEX MATCHALL
    "ROOT_BUILD_OPTION[(]([^ ]+) "
    all_modules
    "${GITGREP}"
  )
  string(REGEX REPLACE
    "ROOT_BUILD_OPTION[(]([^ ])" "\\1"
    all_modules
    ${all_modules}
  )
  string(REPLACE " " ";" all_modules ${all_modules})
  # Remove build configuration settings: they are not modules.
  list(REMOVE_ITEM all_modules
    builtin_llvm
    builtin_clang
    ccache
    cxx11
    cxx14
    cxx17
    cxxmodules
    exceptions
    explicitlink
    gnuinstall
    jemalloc
    macos_native
    memory_termination
    pch
    pyroot_experimental
    rpath
    runtime_cxxmodules
    shared
    tcmalloc
    winrtdebug
    coverage
  )
  set(all_modules ${all_modules} PARENT_SCOPE)
endfunction()


#
#  Get all supported modules as ${all_supported}, on Windows.
#  Get all optional builtins as ${optional_builtins}.
#
function(GET_ALL_SUPPORTED_MODULES_WIN32 LABEL)
  set(all_supported
    builtin_afterimage
    builtin_freetype
    builtin_ftgl
    builtin_gl2ps
    builtin_glew
    builtin_lzma
    builtin_lz4
    builtin_pcre
    builtin_xxhash
    builtin_zlib
    asimage
    astiff
    clad
    cling
    fftw3
    gdml
    http
    minuit2
    opengl
    python
    roofit
    root7
    sqlite
    table
    thread
  )

  if ("${ROOT_VERSION}" VERSION_GREATER "6.15")
    list(APPEND all_supported
      builtin_tbb
      builtin_unuran
      imt
      unuran
    )
  endif()
  set(all_supported ${all_supported} PARENT_SCOPE)
  set(optional_builtins "" PARENT_SCOPE)
endfunction()

#
#  Get all supported modules as ${all_supported}, on MacOS.
#  Get all optional builtins as ${optional_builtins}.
#
function(GET_ALL_SUPPORTED_MODULES_APPLE LABEL)
  set(all_supported
    builtin_afterimage
    builtin_cfitsio
    builtin_davix
    builtin_fftw3
    builtin_freetype
    builtin_ftgl
    builtin_gl2ps
    builtin_glew
    builtin_gsl
    builtin_lzma
    builtin_lz4
    builtin_openssl
    builtin_pcre
    builtin_tbb
    builtin_unuran
    builtin_vc
    builtin_vdt
    builtin_veccore
    builtin_xrootd
    builtin_xxhash
    asimage
    astiff
    bonjour
    clad
    cling
    cocoa
    davix
    fftw3
    fitsio
    fortran
    freetype
    ftgl
    gdml
    http
    imt
    krb5
    ldap
    libcxx
    mathmore
    memstat
    minuit2
    opengl
    python
    roofit
    root7
    sqlite
    ssl
    table
    thread
    tmva
    tmva-cpu
    tmva-pymva
    unuran
    vdt
    veccore
    xml
    xrootd
  )
  set(all_supported ${all_supported} PARENT_SCOPE)
  set(optional_builtins "" PARENT_SCOPE)
endfunction()

#
#  Get all supported modules as ${all_supported}, on Linux.
#  Get all optional builtins as ${optional_builtins}.
#
function(GET_ALL_SUPPORTED_MODULES_LINUX LABEL)
  set(all_supported
    builtin_vdt
    builtin_veccore

    asimage
    astiff
    bonjour
    clad
    cling
    davix
    fftw3
    fitsio
    fortran
    gdml
    gviz
    http
    krb5
    ldap
    mathmore
    memstat
    minuit2
    mysql
    odbc
    opengl
    pgsql
    pythia8
    python
    qt
    qtgsi
    roofit
    root7
    shadowpw
    soversion
    sqlite
    ssl
    table
    thread
    tmva
    tmva-cpu
    tmva-pymva
    tmva-rmva
    unuran
    vdt
    veccore
    x11
    xft
    xml
    xrootd
  )

  # Modules that we can only build on selected platforms.
  # Keep this "open ended", i.e. assume that if Ubuntu18 can do it,
  # Ubuntu22 will also be able to do it.

  # Rinside uses wrong C++ std (missing abi tag for C++11)
  if(NOT "${LABEL}" MATCHES "centos7-clangHEAD")
    list(APPEND all_supported
      r
    )
  endif()

  if("${LABEL}" MATCHES "fedora|ubuntu" AND
     NOT ("${LABEL}" MATCHES "ubuntu1[46]"))
    # Fedora and Ubuntu 18 and up:
    list(APPEND all_supported
      qt5web
    )
  endif()

  if("${LABEL}" MATCHES "centos")
    list(APPEND all_supported
      castor
      globus
      rfio
    )
  endif()

  if("${LABEL}" MATCHES "ubuntu" AND
     NOT ("${LABEL}" MATCHES "ubuntu1[48]"))
    # Ubuntu 14 too old, Ubuntu 18 has a CUDA runtime dev that cannot be
    # compiled with their default compiler...
    list(APPEND all_supported
      cuda
      tmva-gpu
    )
  endif()

  if("${LABEL}" MATCHES "fedora27")
    # OpenBlas 3.2 has a bug that causes test failures.
    # Use the generic, slower one from Netlib instead.
    set(ENV{ExtraCMakeOptions} "-DBLA_VENDOR=Generic $ENV{ExtraCMakeOptions}")
  endif()

  if("${LABEL}" MATCHES "fedora")
    list(APPEND all_supported
      hdfs
    )
  endif()

  if("${LABEL}" MATCHES "centos|fedora")
    list(APPEND all_supported
      dcache
      gfal
    )
  endif()

  if("${LABEL}" MATCHES "fedora|ubuntu" AND
     NOT ("${LABEL}" MATCHES "ubuntu14"))
    # vc needs GCC >= 5
    list(APPEND all_supported
      builtin_vc
      vc
    )
  endif()


  # DO NOT use "open ended" matches, i.e. "no Ubuntu supports X".
  # We want to see whether the next Ubuntu version provides a package,
  # and for that we should not treat it special.

  if (ROOT_VERSION VERSION_GREATER 6.14)
    if("${LABEL}" MATCHES "ubuntu1[468]|fedora2[789]|centos7")
      list(APPEND all_supported
        builtin_tbb
      )
    endif()
  endif()

  if("${LABEL}" MATCHES "ubuntu1[468]|fedora27|centos7")
    # LZ4 is too old.
    list(APPEND all_supported
      builtin_lz4
    )
  endif()

  if("${LABEL}" MATCHES "ubuntu1[468]")
    # Davix is there but in a Davix version that's broken.
    # The others don't exist
    list(APPEND all_supported
      builtin_davix
      builtin_unuran
      builtin_xxhash
    )
  endif()

  if("${LABEL}" MATCHES "centos7-clangHEAD")
    # clang's C++17 does not work with old C++ standard's libraries
    list(APPEND all_supported
      builtin_davix
      builtin_xrootd
    )
  endif()

  if("${LABEL}" MATCHES "ubuntu")
    list(APPEND all_supported
      builtin_afterimage
    )
  endif()

  set(OPTIONAL_BUILTINS
    builtin_afterimage
    builtin_cfitsio
    builtin_davix
    builtin_fftw3
    builtin_freetype
    builtin_ftgl
    builtin_gl2ps
    builtin_glew
    builtin_gsl
    builtin_lzma
    builtin_lz4
    builtin_openssl
    builtin_pcre
    builtin_tbb
    builtin_unuran
    builtin_vc
    builtin_vdt
    builtin_veccore
    builtin_xrootd
    builtin_xxhash
    builtin_zlib
  )
  list(REMOVE_ITEM OPTIONAL_BUILTINS ${all_supported})

  set(all_supported ${all_supported} PARENT_SCOPE)
  set(optional_builtins ${OPTIONAL_BUILTINS} PARENT_SCOPE)
endfunction()


#
#  Get the subset of MODULES that is supported on the current platform.
#  Returns ${supported_modules}.
#
function(FILTER_PLATFORM_SUPPORTED_MODULES MODULES)
  if(WIN32)
    GET_ALL_SUPPORTED_MODULES_WIN32("$ENV{LABEL}")
  elseif(APPLE)
    GET_ALL_SUPPORTED_MODULES_APPLE("$ENV{LABEL}")
  else()
    GET_ALL_SUPPORTED_MODULES_LINUX("$ENV{LABEL}")
  endif()
  message("AXEL: all_supported=${all_supported}")

  # Unsupported modules are those that are in MODULES but not in ${all_supported}
  set(MODULES_UNSUPPORTED ${MODULES})
  list(REMOVE_ITEM MODULES_UNSUPPORTED ${all_supported})
  message("AXEL: MODULES_UNSUPPORTED=${MODULES_UNSUPPORTED}")

  # Supported modules are those in MODULES that are not unsupported.
  list(REMOVE_ITEM MODULES ${MODULES_UNSUPPORTED})
  set(supported_modules ${MODULES} PARENT_SCOPE)
  set(optional_builtins ${optional_builtins} PARENT_SCOPE)
  message("AXEL: supported_modules=${MODULES}")
  message("AXEL: optional_builtins=${optional_builtins}")
endfunction()


#
#  Get modules to enable for a nightly or incremental build, if supported
#  on the current platform. Use as many packages from the distro as possible.
#  Returned as ${want_modules}
#
function(GET_MOST_MODULES ALL_MODULES)
  FILTER_PLATFORM_SUPPORTED_MODULES("${ALL_MODULES}")

  set(want_modules ${supported_modules} PARENT_SCOPE)
  set(optional_builtins ${optional_builtins} PARENT_SCOPE)
endfunction()


#
#  Get modules to enable for a package or pullrequests build, if supported
#  on the current platform. Only important modules will be enabled.
#  Returned as ${want_modules}
#
function(GET_RELEASE_MODULES ALL_MODULES)
  GET_MOST_MODULES("${ALL_MODULES}")

  # Build as stand-alone as possible: add optional builtins.
  list(APPEND want_modules ${optional_builtins})

  # We don't want to include these modules in releases:
  list(REMOVE_ITEM want_modules
    afdsmgrd
    alien
    arrow
    bonjour
    castor
    cefweb
    cuda
    dcache
    geocad
    gfal
    globus
    gviz
    hdfs
    krb5
    ldap
    memstat
    monalisa
    odbc
    oracle
    r
    rfio
    table
    tmva-gpu
    tmva-rmva
    vecgeom
  )
  if (ROOT_VERSION VERSION_LESS 6.16)
    # Releasing with soversion enabled starting v6.16
    list(REMOVE_ITEM want_modules
      soversion
    )
  endif()

  set(want_modules ${want_modules} PARENT_SCOPE)
endfunction()


#
#  Remove modules that cannot be built given the SPECLIST.
#
function(REMOVE_SPEC_SUPPRESSED SPECLIST want_modules)
  if("rtcxxmod" IN_LIST SPECLIST)
    # cling complains about cfitsio version mismatch header/library.
    # cuda fails with `mwaitxintrin.h(36): error: identifier "__builtin_ia32_monitorx" is undefined`
    list(REMOVE_ITEM want_modules
      builtin_cfitsio
      fitsio
      cuda
      tmva_gpu
    )
  endif()
  if("cxx17" IN_LIST SPECLIST)
    # builtin_xrootd cannot be built with C++17.
    list(REMOVE_ITEM want_modules
      buildin_xrootd
    )
  endif()
  if("cxxmod" IN_LIST SPECLIST)
    # The module build currently fails to compile gfal.
    list(REMOVE_ITEM want_modules
      gfal
    )
  endif()
  set(want_modules ${want_modules} PARENT_SCOPE)
endfunction()


#
#  Get modules to enable for this build, on this platform, given the SPECLIST.
#  Return as ${enabled_modules}
#
function(GET_MODULES SPECLIST)
  GET_ALL_MODULES()
  list(SORT all_modules)
  message("AXEL: all modules = ${all_modules}")

  if(CTEST_MODE STREQUAL package OR CTEST_MODE STREQUAL pullrequests)
    GET_RELEASE_MODULES("${all_modules}")
  else()
    GET_MOST_MODULES("${all_modules}")
  endif()


  REMOVE_SPEC_SUPPRESSED("${SPECLIST}" "${want_modules}")
  message("AXEL: modules after removing SPEC suppressed = ${all_modules}")

  set(enabled_modules "")
  foreach(module IN LISTS all_modules)
    list(FIND want_modules ${module} FOUNDIDX)
    if(FOUNDIDX EQUAL -1)
      set(enabled_modules "${enabled_modules} -D${module}=Off")
    else()
      set(enabled_modules "${enabled_modules} -D${module}=On")
    endif()
  endforeach()
  set(enabled_modules ${enabled_modules} PARENT_SCOPE)
endfunction()


#
#  MAIN(), sort of.
#


# First build a list out of spec1-spec2-spec3 for easier matching.
string(REPLACE "-" ";" SPECLIST "$ENV{SPEC}")

#---Select modules to enable as ${enabled_modules}--------------------------
GET_MODULES("${SPECLIST}")
message("AXEL: ${enabled_modules}")

#---Enable tests------------------------------------------------------------
if(NOT CTEST_MODE STREQUAL package)
  set(testing_options "-Dtesting=ON")
  if(CTEST_VERSION STREQUAL "master" OR CTEST_VERSION MATCHES "^v6-")
    if(NOT WIN32)
      set(testing_options "${testing_options} -Droottest=ON")
    endif()
  endif()

  #---Set TCMalloc for fast builds------------------------------------------
  if(CTEST_BUILD_CONFIGURATION STREQUAL "Optimized")
    set(testing_options ${testing_options}" -Dtcmalloc=ON")
  endif()
endif()

#---Use ccache--------------------------------------------------------------
if((NOT CTEST_MODE STREQUAL package) AND (NOT "$ENV{LABEL}" MATCHES "centos7-manycore"))
  set(ccache_option "-Dccache=ON")
endif()

#---Consider SPEC flags-----------------------------------------------------

set(specflags "")
if("python3" IN_LIST SPECLIST)
  find_program(PYTHON3PATH python3)
  if(${PYTHON3PATH} STREQUAL "NOTFOUND")
    message(FATAL_ERROR "Cannot find Python3 for this python3 build!")
  endif()
  set(specflags "${specflags} -DPYTHON_EXECUTABLE=${PYTHON3PATH}")
endif()

if("noimt" IN_LIST SPECLIST)
  string(REGEX REPLACE "-Dimt=[^ ]+ ?" "" enabled_modules ${enabled_modules})
  string(REGEX REPLACE "-Dbuiltin_tbb=[^ ]+ ?" "" enabled_modules ${enabled_modules})
  set(specflags "${specflags} -Dimt=Off -Dbuiltin_tbb=Off")
endif()

if("rtcxxmod" IN_LIST SPECLIST)
  set(specflags "${specflags} -Druntime_cxxmodules=On")
endif()

if("cxxmod" IN_LIST SPECLIST)
  set(specflags "${specflags} -Dcxxmodules=On")
  # Enable incremental builds for cxxmodules
  set(ENV{LIBCLANG_DISABLE_PCH_VALIDATION} 1)
endif()

if("cxx14" IN_LIST SPECLIST)
  set(options ${options} -Dcxx14=ON)
elseif("cxx17" IN_LIST SPECLIST)
  set(options ${options} -Dcxx17=ON)
else()
  set(options ${options} -Dcxx11=ON)
endif()

#---Compose the configuration options---------------------------------------
# Do we want -DCMAKE_VERBOSE_MAKEFILE=ON? Makes builds slow due to text output.
set(options
  -Dfail-on-missing=On
  ${enabled_modules}
  ${specflags}
  ${ccache_option}
  ${testing_options}
  -DCMAKE_INSTALL_PREFIX=${CTEST_INSTALL_DIRECTORY}
  $ENV{ExtraCMakeOptions}
)


#---Configure generator-----------------------------------------------------
if(CTEST_MODE STREQUAL continuous OR CTEST_MODE STREQUAL pullrequests)
  find_program(NINJA_EXECUTABLE ninja)
  if(NINJA_EXECUTABLE)
    set(CTEST_CMAKE_GENERATOR "Ninja")
  endif()
endif()

if ((CMAKE_GENERATOR MATCHES "Visual Studio") AND (CMAKE_GENERATOR_TOOLSET STREQUAL ""))
  set(options ${options} -Thost=x64)
endif()

separate_arguments(options)


#---Handle cxxmodules and coverity builds' checkout behavior----------------
if("$ENV{BUILDOPTS}" STREQUAL "cxxmodules" OR
   "$ENV{BUILDOPTS}" STREQUAL "coverity")
  unset(CTEST_CHECKOUT_COMMAND)
endif()

#----Continuous-----------------------------------------------------------
if(CTEST_MODE STREQUAL continuous)
  set(empty $ENV{EMPTY_BINARY})
  if(empty)
    #ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
    file(REMOVE_RECURSE ${CTEST_BINARY_DIRECTORY})
  else()
    file(GLOB testruns ${CTEST_BINARY_DIRECTORY}/Testing/*-*)
    if(testruns)
      file(REMOVE_RECURSE ${testruns})
    endif()
  endif()
  ctest_start (Continuous TRACK Incremental)
  ctest_update(RETURN_VALUE updates)
  if(NOT EXISTS ${CTEST_BINARY_DIRECTORY}/CMakeCache.txt)
    ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}
                    SOURCE  ${CTEST_SOURCE_DIRECTORY}
                    OPTIONS "${options}" RETURN_VALUE status)
    if(NOT ${status} EQUAL 0)
      message(FATAL_ERROR "Failed to configure project")
    endif()
  endif()
  ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
  ctest_build(BUILD ${CTEST_BINARY_DIRECTORY})
  ctest_submit(PARTS Update Configure Build)

#---Install---------------------------------------------------------------
elseif(CTEST_MODE STREQUAL install)

  #ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
  file(REMOVE_RECURSE ${CTEST_BINARY_DIRECTORY})
  ctest_start(${CTEST_MODE} TRACK Install)
  ctest_update()
  ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}
                  SOURCE  ${CTEST_SOURCE_DIRECTORY}
                  OPTIONS "${options}" APPEND
                  RETURN_VALUE status)
  if(NOT ${status} EQUAL 0)
    message(FATAL_ERROR "Failed to configure project")
  endif()
  ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
  ctest_build(BUILD ${CTEST_BINARY_DIRECTORY} TARGET install APPEND)
  ctest_submit(PARTS Update Configure Build)
  #ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
  file(REMOVE_RECURSE ${CTEST_BINARY_DIRECTORY})

#---Package---------------------------------------------------------------
elseif(CTEST_MODE STREQUAL package)

  #ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
  file(REMOVE_RECURSE ${CTEST_BINARY_DIRECTORY})
  ctest_start(${CTEST_MODE} TRACK Package)
  ctest_update()
  ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}
                  SOURCE  ${CTEST_SOURCE_DIRECTORY}
                  OPTIONS "${options}" APPEND
                  RETURN_VALUE status)
  if(NOT ${status} EQUAL 0)
    message(FATAL_ERROR "Failed to configure project")
  endif()
  ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
  ctest_build(BUILD ${CTEST_BINARY_DIRECTORY} TARGET package APPEND)
  ctest_submit(PARTS Update Configure Build)

#----Pullrequests-----------------------------------------------------------
elseif(CTEST_MODE STREQUAL pullrequests)

  file(REMOVE_RECURSE ${CTEST_BINARY_DIRECTORY})

  # The code semantically does the following:
  # 1. Resets the working area (and checks out the ghprbTargetBranch aka master).
  # 2. git fetch https://github.com/AUTHOR_ID/root.git REMOTE_BRANCH_NAME:LOCAL_BRANCH_NAME
  # 3. git rebase master

  set(REMOTE_BRANCH_NAME "$ENV{ghprbSourceBranch}")
  set(LOCAL_BRANCH_NAME "$ENV{ghprbPullAuthorLogin}-$ENV{ghprbSourceBranch}")

  # Use --git-dir as -C isn't available for old git.
  # FIXME: This can go if we have newer git versions supporting git -C.
  set(GIT_WORKING_DIR "--git-dir=${REBASE_WORKING_DIR}/.git/ --work-tree=${REBASE_WORKING_DIR}")

  # Clean up the area here. If for some reason the rebase screwed up we do not
  # need to wait N times the rest of the cleanup procedures to kick in.
  cleanup_pr_area($ENV{ghprbTargetBranch} ${LOCAL_BRANCH_NAME} ${REBASE_WORKING_DIR})

  execute_process(COMMAND ${CTEST_GIT_COMMAND} fetch $ENV{ghprbAuthorRepoGitUrl} ${REMOTE_BRANCH_NAME}:${LOCAL_BRANCH_NAME} WORKING_DIRECTORY ${REBASE_WORKING_DIR})

  # git rebase master LOCAL_BRANCH_NAME rebases the LOCAL_BRANCH_NAME on master and checks out LOCAL_BRANCH_NAME.
  # Note that we cannot rebase against origin/master because sometimes (for an unknown to me reason)
  # origin/master is behind master. It is likely due to the git fetch configuration on the nodes.
  set(ERROR_OCCURRED 0)
  execute_process(COMMAND  ${CTEST_GIT_COMMAND} -c user.name=sftnight
    -c user.email=sftnight@cern.ch rebase -f -v $ENV{ghprbTargetBranch} ${LOCAL_BRANCH_NAME}
    WORKING_DIRECTORY ${REBASE_WORKING_DIR}
    TIMEOUT 300
    RESULT_VARIABLE ERROR_OCCURRED
    )
  if (ERROR_OCCURRED)
    # We are in the error case, switch to master to clean up the created branch.
    cleanup_pr_area($ENV{ghprbTargetBranch} ${LOCAL_BRANCH_NAME} ${REBASE_WORKING_DIR})
    message(FATAL_ERROR "Rebase of ${LOCAL_BRANCH_NAME} branch on top of $ENV{ghprbTargetBranch} failed!")
  endif()

  # A PR can require changes to root.git and roottest.git. Try switching root or roottest
  # (depending if the PR build was triggered from root or roottest repo) to AUTHOR_ID-BRANCH_NAME if
  # we have if. This ensures consistent building and testing.
  set(FETCH_FAILED)

  # Clean up the area of the 'other' repository, too.
  cleanup_pr_area($ENV{ghprbTargetBranch} ${LOCAL_BRANCH_NAME} ${OTHER_REPO_FOR_BRANCH_SYNC_SOURCE_DIR})

  execute_process(COMMAND ${CTEST_GIT_COMMAND} fetch ${OTHER_REPO_FOR_BRANCH_SYNC_GIT_URL} ${REMOTE_BRANCH_NAME}:${LOCAL_BRANCH_NAME}
    WORKING_DIRECTORY "${OTHER_REPO_FOR_BRANCH_SYNC_SOURCE_DIR}"
    RESULT_VARIABLE FETCH_FAILED)

  # If fetch failed this means the user did not have the clone of root/roottest or did not have a branch
  # with the expected name. Ignore and continue.
  if(NOT FETCH_FAILED)
    message(WARNING "Found remote ${OTHER_REPO_FOR_BRANCH_SYNC_GIT_URL} with corresponding branch name ${REMOTE_BRANCH_NAME}. \
Integrating against it. Please make sure you open and merge a PR against it.")
    # If we have a corresponding branch, check it out and rebase it as we do for above.
    # FIXME: Figure out how to factor out the rebase cmake fragments.
    execute_process(COMMAND  ${CTEST_GIT_COMMAND} checkout -f $ENV{ghprbTargetBranch}
      WORKING_DIRECTORY ${OTHER_REPO_FOR_BRANCH_SYNC_SOURCE_DIR})
    execute_process(COMMAND  ${CTEST_GIT_COMMAND} -c user.name=sftnight
      -c user.email=sftnight@cern.ch rebase -f -v $ENV{ghprbTargetBranch} ${LOCAL_BRANCH_NAME}
      WORKING_DIRECTORY ${OTHER_REPO_FOR_BRANCH_SYNC_SOURCE_DIR}
      TIMEOUT 300
      RESULT_VARIABLE ERROR_OCCURRED
      )
    if (ERROR_OCCURRED)
      cleanup_pr_area($ENV{ghprbTargetBranch} ${LOCAL_BRANCH_NAME} ${OTHER_REPO_FOR_BRANCH_SYNC_SOURCE_DIR})
      message(FATAL_ERROR "Rebase of ${LOCAL_BRANCH_NAME} branch on top of $ENV{ghprbTargetBranch} in ${WARNING_OTHER_REPO} failed!")
    endif()
  endif()

  ctest_start (Pullrequests TRACK Pullrequests)

  # Note that we cannot use CTEST_GIT_UPDATE_CUSTOM to host our rebase command because cdash will
  # start showing all changes from the PR's HEAD (which can be very old) to current master.
  # In order to workaround this issue we do the rebase outside of the ctest update system. Then,
  # we checkout the master branch and then checkout the already rebased branch. This way we trick
  # ctest_update to pick up only the relevant differences.
  execute_process(COMMAND  ${CTEST_GIT_COMMAND} checkout -f $ENV{ghprbTargetBranch} WORKING_DIRECTORY ${REBASE_WORKING_DIR})

  # Do not put ${CTEST_GIT_COMMAND} checkout ${LOCAL_BRANCH_NAME} in quotes! It breaks ctest_update.
  set(CTEST_GIT_UPDATE_CUSTOM ${CTEST_GIT_COMMAND} checkout ${LOCAL_BRANCH_NAME})
  ctest_update(SOURCE "${REBASE_WORKING_DIR}" RETURN_VALUE updates)

  if(updates LESS 0) # stop if update error
    # We are in the error case, switch to master to clean up the created branch.
    cleanup_pr_area($ENV{ghprbTargetBranch} ${LOCAL_BRANCH_NAME} ${REBASE_WORKING_DIR})
    ctest_submit(PARTS Update)
    message(FATAL_ERROR "There are no updated files. Perhaps the rebase of ${LOCAL_BRANCH_NAME} branch on top of $ENV{ghprbTargetBranch} failed!")
  endif()
  ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}
                  SOURCE  ${CTEST_SOURCE_DIRECTORY}
                  OPTIONS "${options}" RETURN_VALUE status)
  if(NOT ${status} EQUAL 0)
    message(FATAL_ERROR "Failed to configure project")
  endif()
  ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
  ctest_build(BUILD ${CTEST_BINARY_DIRECTORY})
  ctest_submit(PARTS Update Configure Build)

  # We must not delete the branches here. They are deleted *after* running ctest (in root-test.cmake).


#---Experimental/Nightly----------------------------------------------------
else()

  #ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
  file(REMOVE_RECURSE ${CTEST_BINARY_DIRECTORY})
  ctest_start(${CTEST_MODE})
  ctest_update(SOURCE ${CTEST_SOURCE_DIRECTORY})
  ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}
                  SOURCE  ${CTEST_SOURCE_DIRECTORY}
                  OPTIONS "${options}" RETURN_VALUE status)
  if(NOT ${status} EQUAL 0)
    message(FATAL_ERROR "Failed to configure project")
  endif()
  ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
  ctest_build(BUILD ${CTEST_BINARY_DIRECTORY})
  ctest_submit(PARTS Update Configure Build)
endif()
