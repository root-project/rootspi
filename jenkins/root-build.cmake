#---Common Setting----------------------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/rootCommon.cmake)

#
#  Initialize enabled_packages for a package and pullrequests build
#
function(INIT_RELEASE_MODULES)
  set(possibly_enabled
    bonjour
    builtin_davix
    builtin_fftw3
    builtin_freetype
    builtin_ftgl
    builtin_gl2ps
    builtin_glew
    builtin_gsl
    builtin_lz4
    builtin_openssl
    builtin_tbb
    builtin_vc
    builtin_vdt
    builtin_xrootd
    castor
    cocoa
    davix
    fftw3
    fitsio
    fortran
    gdml
    gfal
    globus
    gsl
    gviz
    http
    imt
    krb5
    macos_native
    mathmore
    minuit2
    mysql
    oracle
    pch
    pgsql
    pythia6
    pythia8
    python
    qt
    qtgsi
    roofit
    sqlite
    ssl
    tmva
    tmva-cpu
    tmva-gpu
    tmva-pymva
    unuran
    vc
    vdt
    veccore
    xml
    x11
    xft
    xrootd
  )

  # Turn them on by default:
  foreach(package IN LISTS possibly_enabled)
    set(enable_${package} "On")
  endforeach()
  set(enable_bonjour "Off")
  set(enable_builtin_fftw3 "Off")
  set(enable_builtin_freetype "Off")
  set(enable_builtin_ftgl "Off")
  set(enable_builtin_gl2ps "Off")
  set(enable_builtin_glew "Off")
  set(enable_builtin_gsl "Off")
  set(enable_builtin_lz4 "Off")
  set(enable_builtin_openssl "Off")
  set(enable_builtin_tbb "On")
  set(enable_castor "Off")
  set(enable_cocoa "Off")
  set(enable_gfal "Off")
  set(enable_globus "Off")
  set(enable_gviz "Off")
  set(enable_macos_native "Off")
  set(enable_mysql "Off")
  set(enable_oracle "Off")
  set(enable_pgsql "Off")
  set(enable_pythia6 "Off")
  set(enable_pythia8 "Off")
  set(enable_qt "Off")
  set(enable_qtgsi "Off")
  set(enable_sqlite "Off") #OUCH! Our Fedoras and CC don't have it.
  set(enable_tmva-gpu "Off")
  set(enable_x11 "Off")
  set(enable_xft "Off")

  if(WIN32)
    set(enable_builtin_davix "Off")
    set(enable_builtin_freetype "On")
    set(enable_builtin_ftgl "On")
    set(enable_builtin_gl2ps "On")
    set(enable_builtin_glew "On")
    set(enable_builtin_vc "Off")
    set(enable_builtin_vdt "Off")
    set(enable_builtin_xrootd "Off")
    set(enable_davix "Off")
    set(enable_fftw3 "Off")
    set(enable_fitsio "Off")
    set(enable_fortran "Off")
    set(enable_imt "Off")
    set(enable_gsl "Off")
    set(enable_krb5 "Off")
    set(enable_mathmore "Off")
    set(enable_ssl "Off")
    set(enable_tmva "Off")
    set(enable_tmva-cpu "Off")
    set(enable_tmva-pymva "Off")
    set(enable_vc "Off")
    set(enable_vdt "Off")
    set(enable_veccore "Off")
    set(enable_xml "Off")
    set(enable_xrootd "Off")

    if (("${CTEST_VERSION}" MATCHES "^v6-1[0-5].*")
        OR ("${CTEST_VERSION}" MATCHES "^v6-0[0-9].*")
        OR ("${CTEST_VERSION}" MATCHES "^v5.*"))
      # before v6.16:
      set(enable_unuran "Off")
      set(enable_imt "Off")
    endif()

  elseif(APPLE)
    set(enable_bonjour="On")
    set(enable_builtin_fftw3 "On")
    set(enable_builtin_glew "On")
    set(enable_builtin_gsl "On")
    set(enable_builtin_openssl "On")
    set(enable_builtin_tbb "On")
    set(enable_cocoa "On")
    set(enable_macos_native "On")
    set(enable_sqlite "On")

  elseif("$ENV{LABEL}" MATCHES "centos7")
    # We don't have all required packages installed yet.
    set(enable_builtin_davix "On")
    set(enable_builtin_fftw3 "On")
    set(enable_builtin_gsl "On")
    set(enable_davix "On")
    set(enable_fftw3 "On")
    set(enable_fitsio "Off")
    set(enable_globus "On")
    set(enable_mathmore "On")
    set(enable_tmva-pymva "Off")

  else()
    #LINUX
    set(enable_builtin_lz4 "On") # everyone's LZ4 is too old
    set(enable_pythia8 "On")
    set(enable_qt "On")
    set(enable_qtgsi "On")
    set(enable_x11 "On")
    set(enable_xft "On")

    if("${tag}" MATCHES ".*fedora29.*")
      # Qt5 us too new.
      set(enable_qt "Off")
      set(enable_qtgsi "Off")
    endif()

    if("$ENV{LABEL}" MATCHES "ubuntu14")
      # Compiler too old for Vc
      set(enable_vc "Off")
      set(enable veccore "Off")
      # Davix too old
      set(enable_builtin_davix "On")
    elseif("$ENV{LABEL}" MATCHES "ubuntu")
      # Davix too old
      set(enable_builtin_davix "On")
    endif()
  endif()

  # Collect enabled / disabled into a CMake argument list:
  set(ep "-Dall=Off")
  foreach(package IN LISTS possibly_enabled)
    set(ep "${ep} -D${package}=${enable_${package}}")
  endforeach()
  set(enabled_packages "${ep}" PARENT_SCOPE)
endfunction()


#
#  Initialize enabled_packages for a nightly or incremental build
#
function(INIT_MOST_MODULES)
  if(WIN32)
    INIT_RELEASE_MODULES()
    set(enabled_packages "${enabled_packages}" PARENT_SCOPE)
  elseif(APPLE)
    INIT_RELEASE_MODULES()
    set(enabled_packages "${enabled_packages}" PARENT_SCOPE)
  elseif("$ENV{LABEL}" MATCHES "centos7")
    # We don't have all required packages installed yet.
    INIT_RELEASE_MODULES()
    set(enabled_packages "${enabled_packages}" PARENT_SCOPE)
  else()
    set(ep "-Dall=On -Dbuiltin_tbb=On -Dbuiltin_veccore=On -Dbuiltin_vc=On -Dbuiltin_vdt=On -Dbuiltin_lz4=On")
    set(disable_these
      arrow
      castor
      chirp
      glite
      hdfs
      monalisa
      oracle
      pythia6
      rfio
      sapdb
      srp
    )
    foreach(package IN LISTS disable_these)
      set(ep "${ep} -D${package}=Off")
    endforeach()

    if("$ENV{LABEL}" MATCHES "ubuntu14")
      # Compiler too old for Vc
      set(ep "${ep} -Dvc=Off -Dr=Off")
      # Davix too old
      set(ep "${ep} -Dbuiltin_davix=On")
    elseif("$ENV{LABEL}" MATCHES "ubuntu")
      # Davix too old
      set(ep "${ep} -Dbuiltin_davix=On")
    endif()
    set(enabled_packages "${ep}" PARENT_SCOPE)
  endif()
endfunction()


#---Select packages to enable-----------------------------------------------
if(CTEST_MODE STREQUAL package OR CTEST_MODE STREQUAL pullrequests)
  INIT_RELEASE_MODULES()
else()
  INIT_MOST_MODULES()
endif()

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
  ${enabled_packages}
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
