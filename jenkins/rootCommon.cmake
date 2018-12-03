cmake_minimum_required(VERSION 2.8)

#---Utility Macros----------------------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/rootmacros.cmake)

#---Make sure that VERBOSE is OFF to avoid screwing up the build performance
unset(ENV{VERBOSE})

#---General Configuration---------------------------------------------------
GET_PWD(pwd)
GET_HOST(host)
GET_NCPUS(ncpu)
GET_CONFIGURATION_TAG(tag)
#---------------------------------------------------------------------------
set(TypeRelease -opt)
set(TypeDebug   -dbg)
set(TypeOptimized -fst)
set(TypeRelWithDebInfo)
set(TypeMinSizeRel -min)
set(TypeCoverage -cov)

#---Set the source, build directory, mode, buildtype -----------------------
if("$ENV{MODE}" STREQUAL "")
  set(CTEST_MODE Experimental)
else()
  set(CTEST_MODE "$ENV{MODE}")
endif()

if("$ENV{VERSION}" STREQUAL "")
  set(CTEST_VERSION master)
else()
  set(CTEST_VERSION "$ENV{VERSION}")
endif()
if(CTEST_MODE STREQUAL package)
  if((CTEST_VERSION STREQUAL master) OR (CTEST_VERSION MATCHES "-patches$"))
    # If we don't have a tag, set the version to
    # "master_2018-10-31_ae7e81bc30cc" to get a nice package name.
    string(SUBSTRING "$ENV{GIT_COMMIT}" 0 12 PACKAGE_SHORT_GIT_REV)
    if("${PACKAGE_SHORT_GIT_REV}" STREQUAL "")
      message(FATAL_ERROR "Empty git revision!")
    endif()
    string(TIMESTAMP PACKAGE_DATE "%Y-%m-%d")
    set(PACKAGE_VERSION "${CTEST_VERSION}_${PACKAGE_DATE}_${PACKAGE_SHORT_GIT_REV}")
  else()
    string(REPLACE "-" "." PACKAGE_VERSION "${CTEST_VERSION}")
    # But keep v6.13.02-rc1:
    string(REPLACE ".rc" "-rc" PACKAGE_VERSION "${PACKAGE_VERSION}")
  endif()
  message("Package version is ${PACKAGE_VERSION}")
endif()

# Set ROOT_VERSION for simple version comparison using VERSION_GREATER etc.
if(CTEST_VERSION STREQUAL master)
  set(ROOT_VERSION "99.99.999-master") # newer than everything else.
elseif(CTEST_VERSION MATCHES "-patches")
  string(REGEX REPLACE "v([^-]+)-([^-]+)-00-patches" "\\1.\\2.999"
    ROOT_VERSION
    "${CTEST_VERSION}"
  )
else()
  string(REGEX REPLACE "v([^-]+)-([^-]+)-([^-]+)" "\\1.\\2.\\3"
    ROOT_VERSION
    "${CTEST_VERSION}"
  )
endif()
message("Building ROOT version ${ROOT_VERSION}")

if("$ENV{SOURCE_PREFIX}" STREQUAL "")
  set(CTEST_SOURCE_PREFIX "${pwd}/sources")
else()
  set(CTEST_SOURCE_PREFIX "$ENV{SOURCE_PREFIX}")
endif()

if("$ENV{BUILD_PREFIX}" STREQUAL "")
  set(CTEST_BUILD_PREFIX "${pwd}")
else()
  set(CTEST_BUILD_PREFIX "$ENV{BUILD_PREFIX}")
endif()

if("$ENV{BUILDTYPE}" STREQUAL "")
  set(CTEST_BUILD_CONFIGURATION "Release")
else()
  set(CTEST_BUILD_CONFIGURATION "$ENV{BUILDTYPE}")
endif()


if("$ENV{JENKINS_HOME}" STREQUAL "")
  set(CTEST_SOURCE_DIRECTORY ${CTEST_SOURCE_PREFIX}/${CTEST_MODE}-${CTEST_VERSION}-${tag})
  set(CTEST_BINARY_DIRECTORY ${CTEST_BUILD_PREFIX}/build)
  set(CTEST_INSTALL_DIRECTORY ${CTEST_BUILD_PREFIX}/install/${CTEST_MODE}-${CTEST_VERSION}-${tag})
elseif(CTEST_MODE STREQUAL package)
  string(REPLACE "root_v" "root-" TARSRCDIR "root_${PACKAGE_VERSION}")
  set(CTEST_SOURCE_DIRECTORY ${CTEST_SOURCE_PREFIX}/${TARSRCDIR})
  set(CTEST_BINARY_DIRECTORY ${CTEST_BUILD_PREFIX}/build)
  set(CTEST_INSTALL_DIRECTORY ${CTEST_BUILD_PREFIX}/install/ROOT/${TARSRCDIR})
else()
  get_filename_component(CTEST_SOURCE_DIRECTORY root ABSOLUTE)
  get_filename_component(CTEST_BINARY_DIRECTORY build ABSOLUTE)
  get_filename_component(CTEST_INSTALL_DIRECTORY install ABSOLUTE)
endif()

#---------------------------------------------------------------------------

set(CTEST_SITE "${host}")
if(WIN32)
  if(tag MATCHES x64)
    set(win64 " Win64")
  endif()
  if(tag MATCHES vc15)
    set(CTEST_CMAKE_GENERATOR "Visual Studio 15 2017${win64}")
  elseif(tag MATCHES vc13)
    set(CTEST_CMAKE_GENERATOR "Visual Studio 13${win64}")
  elseif(tag MATCHES vc12)
    set(CTEST_CMAKE_GENERATOR "Visual Studio 12${win64}")
  elseif(tag MATCHES vc11)
    set(CTEST_CMAKE_GENERATOR "Visual Studio 11${win64}")
  elseif(tag MATCHES vc10)
    set(CTEST_CMAKE_GENERATOR "Visual Studio 10${win64}")
  elseif(tag MATCHES vc9)
    set(CTEST_CMAKE_GENERATOR "Visual Studio 9 2008${win64}")
  else()
    set(CTEST_CMAKE_GENERATOR "NMake Makefiles")
  endif()
  set(CTEST_BUILD_FLAGS "/maxcpucount")
else()
  set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
  set(CTEST_BUILD_FLAGS "-j${ncpu}")
endif()
set(CTEST_CONFIGURATION_TYPE "${CTEST_BUILD_CONFIGURATION}")
if(NOT "$ENV{BUILDOPTS}"  STREQUAL "" )
  set(Opts -$ENV{BUILDOPTS})
endif()
if("$ENV{ghprbPullId}" STREQUAL "")
  set(CTEST_BUILD_NAME ${CTEST_VERSION}-${tag}${Type$ENV{BUILDTYPE}}${Opts})
else()
  set(CTEST_BUILD_NAME PR-$ENV{ghprbPullId}-${tag}${Type$ENV{BUILDTYPE}}${Opts})
  if($ENV{ghprbGhRepository} STREQUAL "root-project/roottest")
    set(REBASE_WORKING_DIR "${CTEST_SOURCE_DIRECTORY}/../roottest/")
    set(OTHER_REPO_FOR_BRANCH_SYNC_SOURCE_DIR "${CTEST_SOURCE_DIRECTORY}")
    set(OTHER_REPO_FOR_BRANCH_SYNC_GIT_URL "https://github.com/$ENV{ghprbPullAuthorLogin}/root.git")
    set(IS_ROOTTEST_PR 1)
  else()
    set(REBASE_WORKING_DIR "${CTEST_SOURCE_DIRECTORY}")
    set(OTHER_REPO_FOR_BRANCH_SYNC_SOURCE_DIR "${CTEST_SOURCE_DIRECTORY}/../roottest/")
    set(OTHER_REPO_FOR_BRANCH_SYNC_GIT_URL "https://github.com/$ENV{ghprbPullAuthorLogin}/roottest.git")
    set(IS_ROOTTEST_PR 0)
  endif()
endif()

#---CDash settings----------------------------------------------------------
set(CTEST_PROJECT_NAME "ROOT")
set(CTEST_NIGHTLY_START_TIME "00:00:00 CET")
set(CTEST_DROP_METHOD "http")
set(CTEST_DROP_SITE "cdash.cern.ch")
set(CTEST_DROP_LOCATION "/submit.php?project=ROOT")
set(CTEST_DROP_SITE_CDASH TRUE)

#---Custom CTest settings---------------------------------------------------
#set(CTEST_NOTES_FILES  ${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME})
set(CTEST_USE_LAUNCHERS 0)
set(CTEST_CUSTOM_MAXIMUM_PASSED_TEST_OUTPUT_SIZE 64000)

#---Git Stuff--------------------------------------------------------------
find_program(CTEST_GIT_COMMAND NAMES git)

if(NOT EXISTS ${CTEST_SOURCE_DIRECTORY})
  set(CTEST_CHECKOUT_COMMAND "${CTEST_GIT_COMMAND} clone http://root.cern/git/root.git --branch ${CTEST_VERSION} ${CTEST_SOURCE_DIRECTORY}")
else()
  execute_process(COMMAND ${CTEST_GIT_COMMAND} clean -xfq WORKING_DIRECTORY ${CTEST_SOURCE_DIRECTORY})
endif()
set(CTEST_UPDATE_COMMAND ${CTEST_GIT_COMMAND})

if(NOT "$ENV{GIT_COMMIT}" STREQUAL "")  #--- From Jenkins---------------------
  if(CTEST_MODE STREQUAL package AND PACKAGE_DATE)
    file(RENAME "$ENV{WORKSPACE}/root" "${CTEST_SOURCE_DIRECTORY}")
  endif()
  set(CTEST_CHECKOUT_COMMAND "${CMAKE_COMMAND} -E chdir ${CTEST_SOURCE_DIRECTORY} ${CTEST_GIT_COMMAND} checkout -f $ENV{GIT_PREVIOUS_COMMIT}")
  set(CTEST_GIT_UPDATE_CUSTOM  ${CTEST_GIT_COMMAND} checkout -f $ENV{GIT_COMMIT})
endif()

if ((CTEST_MODE STREQUAL package) AND NOT PACKAGE_DATE)
  # this is a tag; grab the sources from http://root.cern/downloads and unpack them.
  unset(CTEST_CHECKOUT_COMMAND)
  set(SOURCE_TAR_FILENAME "root_${PACKAGE_VERSION}.source.tar.gz")
  set(SOURCE_URL "http://root.cern/download/${SOURCE_TAR_FILENAME}")
  file(DOWNLOAD
    ${SOURCE_URL}
    ${CTEST_SOURCE_PREFIX}/${SOURCE_TAR_FILENAME}
    SHOW_PROGRESS
    STATUS DOWNLOADRES
    )
  list(GET DOWNLOADRES 0 ERRORCODE)
  if(NOT ERRORCODE EQUAL 0)
    list(GET DOWNLOADRES 1 ERRORMSG)
    message(FATAL_ERROR "Download of ${SOURCE_URL} failed with code ${ERRORCODE}: ${ERRORMSG}")
  endif()
  file(REMOVE_RECURSE ${CTEST_SOURCE_DIRECTORY})
  execute_process(
    COMMAND ${CMAKE_COMMAND} -E tar xzf ${CTEST_SOURCE_PREFIX}/${SOURCE_TAR_FILENAME}
    WORKING_DIRECTORY ${CTEST_SOURCE_PREFIX}
    RESULT_VARIABLE TAR_RESULT)
  if(NOT ${TAR_RESULT} EQUAL 0)
    message(FATAL_ERROR "Failed to uncompress tar file ${CTEST_SOURCE_PREFIX}/${SOURCE_TAR_FILENAME} into ${CTEST_SOURCE_DI\
RECTORY}: ${TAR_RESULT}")
  endif()
  message("Uncompressed tar file ${CTEST_SOURCE_PREFIX}/${SOURCE_TAR_FILENAME} into ${CTEST_SOURCE_DIRECTORY}")
endif()

#----Recover From Errors------------------------------------------------------
function(cleanup_pr_area target_branch local_branch_name cleanup_working_dir)
  message(STATUS "Cleaning up [git rebase --abort] in ${cleanup_working_dir}")
  execute_process(COMMAND ${CTEST_GIT_COMMAND} rebase --abort WORKING_DIRECTORY ${cleanup_working_dir})

  message(STATUS "Checking out branch ${target_branch} [git checkout ${target_branch}] in ${cleanup_working_dir}")
  # git fetch cannot update the HEAD of the current branch. We should check out some 'safe' branch.
  # The problem can arise if our cleanup failed to checkout different from local_branch_name branch.
  execute_process(COMMAND ${CTEST_GIT_COMMAND} checkout ${target_branch} WORKING_DIRECTORY ${cleanup_working_dir})

  # Check if the branch exists.
  set(branch_missing)
  execute_process(COMMAND  ${CTEST_GIT_COMMAND} rev-parse --quiet --verify ${local_branch_name}
    WORKING_DIRECTORY ${cleanup_working_dir}
    RESULT_VARIABLE branch_missing
    )
  if (NOT branch_missing)
    message(STATUS "Cleaning up [git branch -D ${local_branch_name}] in ${cleanup_working_dir}")
    execute_process(COMMAND ${CTEST_GIT_COMMAND} branch -D ${local_branch_name} WORKING_DIRECTORY ${cleanup_working_dir})
  endif()
endfunction()

