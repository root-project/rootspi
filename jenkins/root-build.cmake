#---Common Setting----------------------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/rootCommon.cmake)

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
if((NOT CTEST_MODE STREQUAL package) AND (NOT "$ENV{JOB_BASE_NAME}" MATCHES ".*centos7-manycore.*"))
  set(ccache_option "-Dccache=ON")
endif()

#---Select packages to enable-----------------------------------------------
set(possibly_enabled
  bonjour
  builtin_davix
  builtin_gsl
  builtin_vc
  castor
  cocoa
  davix
  fftw3
  fitsio
  fortran
  gdml
  gfal
  gsl
  http
  imt
  krb5
  macos_native
  mathmore
  minuit2
  mysql
  opengl
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
  unuran
  vc
  vdt
  xml
  x11
  xft
  xrootd
)

# Turn them on by default:
foreach(package IN LISTS possibly_enabled)
  set(enable_${package} "On")
endforeach()
#...except these:
set(enable_bonjour "Off")
set(enable_builtin_gsl "Off")
set(enable_castor "Off")
set(enable_cocoa "Off")
set(enable_gfal "Off")
set(enable_macos_native "Off")
set(enable_mysql "Off")
set(enable_oracle "Off")
set(enable_pgsql "Off")
set(enable_pythia6 "Off")
set(enable_pythia8 "Off")
set(enable_sqlite "Off") #OUCH! Our Fedoras and CC don't have it.
set(enable_tmva-gpu "Off")
set(enable_x11 "Off")
set(enable_xft "Off")

if(WIN32)
  set(enable_builtin_davix "Off")
  set(enable_builtin_vc "Off")
  set(enable_davix "Off")
  set(enable_fftw3 "Off")
  set(enable_fitsio "Off")
  set(enable_fortran "Off")
  set(enable_imt "Off")
  set(enable_gsl "Off")
  set(enable_krb5 "Off")
  set(enable_mathmore "Off")
  set(enable_qt "Off")
  set(enable_qtgsi "Off")
  set(enable_ssl "Off")
  set(enable_tmva "Off")
  set(enable_tmva-cpu "Off")
  set(enable_vc "Off")
  set(enable_vdt "Off")
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
  set(enable_builtin_gsl "On")
  set(enable_cocoa "On")
  set(enable_macos_native "On")
  set(enable_sqlite "On")

else()
  #LINUX
  set(enable_pythia8 "On")
  set(enable_x11 "On")
  set(enable_xft "On")
endif()

# Collect enabled / disabled into a CMake argument list:
set(enabled_packages "")
foreach(package IN LISTS possibly_enabled)
  set(enabled_packages "${enabled_packages} -D${package}=${enable_${package}}")
endforeach()

#---Compose the configuration options---------------------------------------
# Do we want -DCMAKE_VERBOSE_MAKEFILE=ON? Makes builds slow due to text output.
set(options
  -Dfail-on-missing=On
  -Dall=Off
  ${enabled_packages}
  ${ccache_option}
  ${testing_options}
  -DCMAKE_INSTALL_PREFIX=${CTEST_INSTALL_DIRECTORY}
  $ENV{ExtraCMakeOptions}
)
 
#---Special build options---------------------------------------------------
if("$ENV{BUILDOPTS}" STREQUAL "cxx14root7")
  set(options ${options} -Dcxx14=ON -Droot7=ON)
endif()

if("$ENV{CXX_VERSION}" STREQUAL "14")
  set(options ${options} -Dcxx14=ON)
elseif("$ENV{CXX_VERSION}" STREQUAL "17")
  set(options ${options} -Dcxx17=ON)
endif()

if("$ENV{BUILDOPTS}" STREQUAL "cxxmodules" OR
   "$ENV{BUILDOPTS}" STREQUAL "coverity")
  unset(CTEST_CHECKOUT_COMMAND)
endif()

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
