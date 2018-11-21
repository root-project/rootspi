#---Common Setting----------------------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/rootCommon.cmake)

#
#  Initialize ${all_modules} to all available build options.
#
function(GET_ALL_MODULES)
  execute_process(
    COMMAND git grep "^ROOT_BUILD_OPTION" cmake/modules/RootBuildOptions.cmake
    WORKING_DIRECTORY ${CTEST_SOURCE_DIRECTORY}
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
  set(all_modules ${all_modules} PARENT_SCOPE)
  message("AXEL: all modules = ${all_modules}")
endfunction()


#
#  Get all supported modules as ${all_supported}, on Windows.
#  Get all optional builtins as ${optional_builtins}.
#
function(GET_ALL_SUPPORTED_MODULES_WIN32)
  set(all_supported
    builtin_afterimage
    builtin_freetype
    builtin_ftgl
    builtin_gl2ps
    builtin_glew
    builtin_gsl
    builtin_llvm
    builtin_clang
    builtin_lzma
    builtin_lz4
    builtin_pcre
    builtin_tbb
    builtin_unuran
    builtin_xxhash
    builtin_zlib
    asimage
    astiff
    clad
    cling
    cxx14
    exceptions
    explicitlink
    fftw3
    fitsio
    fortran
    gdml
    gviz
    http
    mathmore
    minuit2
    opengl
    pch
    pythia6
    pythia8
    python
    roofit
    root7
    shared
    sqlite
    table
    thread
    unuran
    xml
  )

  if ("${ROOT_VERSION}" VERSION_GREATER "6.15")
    list(APPEND all_supported
      imt
      unuran
    )
  endif()
  set(all_supported "${all_supported}" PARENT_SCOPE)
  set(optional_builtins "" PARENT_SCOPE)
endfunction()

#
#  Get all supported modules as ${all_supported}, on MacOS.
#  Get all optional builtins as ${optional_builtins}.
#
function(GET_ALL_SUPPORTED_MODULES_APPLE)
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
    builtin_llvm
    builtin_clang
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
    cxx11
    cxx14
    cxx17
    davix
    exceptions
    explicitlink
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
    macos_native
    mathmore
    memstat
    minuit2
    opengl
    pch
    python
    roofit
    root7
    shared
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
  set(all_supported "${all_supported}" PARENT_SCOPE)
  set(optional_builtins "" PARENT_SCOPE)
endfunction()

#
#  Get all supported modules as ${all_supported}, on Linux.
#  Get all optional builtins as ${optional_builtins}.
#
function(GET_ALL_SUPPORTED_MODULES_LINUX)
  set(all_supported
    builtin_llvm
    builtin_clang
    builtin_vdt
    builtin_veccore

    asimage
    astiff
    bonjour
    clad
    cling
    davix
    exceptions
    explicitlink
    fftw3
    fitsio
    fortran
    gdml
    gviz
    http
    imt
    krb5
    ldap
    mathmore
    memstat
    minuit2
    mysql
    odbc
    opengl
    pch
    pgsql
    pythia6
    pythia8
    python
    qt
    qtgsi
    r
    roofit
    root7
    shadowpw
    shared
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
    vc
    vdt
    veccore
    x11
    xft
    xml
    xrootd
  )

  if (ROOT_VERSION VERSION_LESS 6.16)
    if("$ENV{LABEL}" MATCHES "ubuntu14" OR
       "$ENV{LABEL}" MATCHES "ubuntu16" OR
       "$ENV{LABEL}" MATCHES "ubuntu18" OR
       "$ENV{LABEL}" MATCHES "fedora27" OR
       "$ENV{LABEL}" MATCHES "fedora28" OR
       "$ENV{LABEL}" MATCHES "fedora29" OR
       "$ENV{LABEL}" MATCHES "centos7")
      list(APPEND all_supported
        builtin_tbb
      )
    endif()
  endif()

  if("$ENV{LABEL}" MATCHES "ubuntu14")
    # LZ4 is too old.
    list(APPEND all_supported
      builtin_lz4
    )
  endif()

  if("$ENV{LABEL}" MATCHES "ubuntu14" OR
     "$ENV{LABEL}" MATCHES "ubuntu16" OR
     "$ENV{LABEL}" MATCHES "ubuntu18")
    # Davix is there but in a Davix version that's broken.
    # The others don't exist
    list(APPEND all_supported
      builtin_davix
      builtin_unuran
      builtin_xrootd
      builtin_xxhash
    )
  endif()

  if("$ENV{LABEL}" MATCHES "fedora" OR
     ("$ENV{LABEL}" MATCHES "ubuntu" AND
      NOT ("$ENV{LABEL}" MATCHES "ubuntu14")))
     # vc needs GCC >= 5
     list(APPEND all_supported
       builtin_vc
     )
  endif()

  if("$ENV{LABEL}" MATCHES "fedora" OR
     ("$ENV{LABEL}" MATCHES "ubuntu"
     AND NOT ("$ENV{LABEL}" MATCHES "ubuntu14" OR
              "$ENV{LABEL}" MATCHES "ubuntu16")))
    # Fedora and Ubuntu 18 and up:
    list(APPEND all_supported
      qt5web
    )
  endif()

  if("$ENV{LABEL}" MATCHES "centos")
    list(APPEND all_supported
      castor
      globus
      rfio
    )
  endif()

  if("$ENV{LABEL}" MATCHES "fedora")
    list(APPEND all_supported
      cuda
      tmva-gpu
      hdfs
    )
  endif()

  if("$ENV{LABEL}" MATCHES "centos" OR
     "$ENV{LABEL}" MATCHES "fedora")
    list(APPEND all_supported
      dcache
      geocad
      gfal
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

  set(all_supported "${all_supported}" PARENT_SCOPE)
  set(optional_builtins "{OPTIONAL_BUILTINS}" PARENT_SCOPE)
endfunction()


#
#  Get the subset of MODULES that is supported on the current platform.
#  Returns ${supported_modules}.
#
function(FILTER_PLATFORM_SUPPORTED_MODULES MODULES)
  if(WIN32)
    GET_ALL_SUPPORTED_MODULES_WIN32()
  elseif(APPLE)
    GET_ALL_SUPPORTED_MODULES_APPLE()
  else()
    GET_ALL_SUPPORTED_MODULES_LINUX()
  endif()
  message("AXEL: all_supported=${all_supported}")

  # Unsupported modules are those that are in MODULES but not in ${all_supported}
  set(MODULES_UNSUPPORTED ${MODULES})
  list(REMOVE_ITEM MODULES_UNSUPPORTED ${all_supported})

  # Supported modules are those in MODULES that are not unsupported.
  list(REMOVE_ITEM MODULES ${MODULES_UNSUPPORTED})
  set(supported_modules "${MODULES}" PARENT_SCOPE)
  set(optional_builtins "{optional_builtins}" PARENT_SCOPE)
  message("AXEL: supported_modules=${supported_modules}")
  message("AXEL: optional_builtins=${optional_builtins}")
endfunction()


#
#  Get modules to enable for a nightly or incremental build, if supported
#  on the current platform. Use as many packages from the distro as possible.
#  Returned as ${want_modules}
#
function(GET_MOST_MODULES ALL_MODULES)
  FILTER_PLATFORM_SUPPORTED_MODULES("${ALL_MODULES}")

  set(want_modules "${supported_modules}" PARENT_SCOPE)
  set(optional_builtins "{optional_builtins}" PARENT_SCOPE)
endfunction()


#
#  Get modules to enable for a package or pullrequests build, if supported
#  on the current platform. Only important modules will be enabled.
#  Returned as ${want_modules}
#
function(GET_RELEASE_MODULES ALL_MODULES)
  GET_MOST_MODULES(${ALL_MODULES})

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
    pythia6
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

  set(want_modules "${want_modules}" PARENT_SCOPE)
endfunction()


#
#  Get modules to enable for this build, on this platform.
#  Return as ${enabled_modules}
#
function(GET_MODULES)
  GET_ALL_MODULES()
  if(CTEST_MODE STREQUAL package OR CTEST_MODE STREQUAL pullrequests)
    GET_RELEASE_MODULES("${all_modules}")
  else()
    GET_MOST_MODULES("${all_modules}")
  endif()
  list(SORT all_modules)
  set(enabled_modules "")
  foreach(module IN LISTS all_modules)
    list(FIND want_modules ${module} FOUNDIDX)
    if(FOUNDIDX EQUAL -1)
      set(enabled_modules "${enabled_modules} -D${module}=Off")
    else()
      set(enabled_modules "${enabled_modules} -D${module}=On")
    endif()
  endforeach()
  set(enabled_modules "${enabled_modules}" PARENT_SCOPE)
endfunction()



#---Select modules to enable as ${enabled_modules}--------------------------
GET_MODULES()
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
if($ENV{SPEC} MATCHES "python3")
  find_program(PYTHON3PATH python3)
  if(${PYTHON3PATH} STREQUAL "NOTFOUND")
    message(FATAL_ERROR "Cannot find Python3 for this python3 build!")
  endif()
  set(specflags "${specflags} -DPYTHON_EXECUTABLE=${PYTHON3PATH}")
endif()

if($ENV{SPEC} MATCHES "noimt")
  set(specflags "${specflags} -Dimt=Off -Dbuiltin_tbb=Off")
endif()

if($ENV{SPEC} MATCHES "rtcxxmod")
  set(specflags "${specflags} -Druntime_cxxmodules=On")
endif()

if("$ENV{SPEC}" MATCHES "cxx14")
  set(options ${options} -Dcxx14=ON)
elseif("$ENV{SPEC}" MATCHES "cxx17")
  set(options ${options} -Dcxx17=ON)
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
  ctest_start (Continuous TRACK Continuous-${CTEST_VERSION})
  ctest_update(RETURN_VALUE updates)
  ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}
                  SOURCE  ${CTEST_SOURCE_DIRECTORY}
                  OPTIONS "${options}" RETURN_VALUE status)
  if(NOT ${status} EQUAL 0)
    message(FATAL_ERROR "Failed to configure project")
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
