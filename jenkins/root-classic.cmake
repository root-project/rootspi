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
set(TypeRelWithDebInfo)
set(TypeMinSizeRel -min)
set(TypeCoverage -cov)

#---Set the source, build directory, mode, buildtype -----------------------
if("$ENV{MODE}" STREQUAL "")
set(CTEST_MODE Experimental)
else()
set(CTEST_MODE "$ENV{MODE}")
endif()

if("$ENV{CTEST_SITE}" STREQUAL "")
  set(CTEST_SITE "${host}")
else()
  set(CTEST_SITE "$ENV{CTEST_SITE}")
  message( "Running build and test on ${host}" )
endif()

if("$ENV{VERSION}" STREQUAL "")
set(CTEST_VERSION master)
else()
set(CTEST_VERSION "$ENV{VERSION}")
endif()

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
  set(CTEST_BINARY_DIRECTORY ${CTEST_BUILD_PREFIX}/${CTEST_MODE}-${CTEST_VERSION}-${tag})
else()
  get_filename_component(CTEST_SOURCE_DIRECTORY root ABSOLUTE)
  get_filename_component(CTEST_BINARY_DIRECTORY build ABSOLUTE)
endif()

#--Customize to GNU make build commands--------------------------------------
find_program(CTEST_GIT_COMMAND NAMES git)

if(NOT EXISTS ${CTEST_SOURCE_DIRECTORY})
  set(CTEST_CHECKOUT_COMMAND "${CTEST_GIT_COMMAND} clone http://root.cern.ch/git/root.git --branch ${CTEST_VERSION} ${CTEST_SOURCE_DIRECTORY}")
endif()

set(CTEST_UPDATE_COMMAND ${CTEST_GIT_COMMAND})

if(NOT "$ENV{GIT_COMMIT}" STREQUAL "")  #--- From Jenkins---------------------
  set(CTEST_CHECKOUT_COMMAND "${CMAKE_COMMAND} -E chdir ${CTEST_SOURCE_DIRECTORY} ${CTEST_GIT_COMMAND} checkout -f $ENV{GIT_PREVIOUS_COMMIT}")
  set(CTEST_GIT_UPDATE_CUSTOM  ${CTEST_GIT_COMMAND} checkout -f $ENV{GIT_COMMIT})
endif()

set(CTEST_CONFIGURE_COMMAND "${CTEST_SOURCE_DIRECTORY}/configure --all")
set(CTEST_BUILD_COMMAND "make -s -i -j${ncpu}")

set(CTEST_CONFIGURATION_TYPE "${CTEST_BUILD_CONFIGURATION}")
set(CTEST_BUILD_NAME ${CTEST_VERSION}-${tag}${Type$ENV{BUILDTYPE}}-classic)

#---CDash settings----------------------------------------------------------
set(CTEST_PROJECT_NAME "ROOT")
set(CTEST_NIGHTLY_START_TIME "00:00:00 CET")
set(CTEST_DROP_METHOD "http")
set(CTEST_DROP_SITE "cdash.cern.ch")
set(CTEST_DROP_LOCATION "/submit.php?project=ROOT")
set(CTEST_DROP_SITE_CDASH TRUE)

#---Addional CTest settings-------------------------------------------------
#set(CTEST_UPDATE_OPTIONS "${CTEST_UPDATE_OPTIONS} -p")  # Add proposed tags
set(CTEST_TEST_TIMEOUT 1500)
set(CTEST_CUSTOM_MAXIMUM_FAILED_TEST_OUTPUT_SIZE "100000")
set(CTEST_CUSTOM_MAXIMUM_PASSED_TEST_OUTPUT_SIZE "10000")

set($ENV{LC_MESSAGES} "en_EN")
set(CTEST_CUSTOM_WARNING_EXCEPTION ${CTEST_CUSTOM_WARNING_EXCEPTION}
  "note: variable tracking size limit exceeded with -fvar-tracking-assignments")

#---Configure tests. Some of them require some files to be copied-----------
file(MAKE_DIRECTORY ${CTEST_BINARY_DIRECTORY})
configure_file(${CTEST_SOURCE_DIRECTORY}/cmake/modules/CTestCustom.cmake ${CTEST_BINARY_DIRECTORY} COPYONLY)

#---CTest commands----------------------------------------------------------
ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
ctest_start(${CTEST_MODE})
ctest_update(SOURCE ${CTEST_SOURCE_DIRECTORY})
ctest_configure(BUILD ${CTEST_BINARY_DIRECTORY} APPEND)

#---Read custom files and generate a note with ignored tests----------------
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
WRITE_INGNORED_TESTS(${CTEST_BINARY_DIRECTORY}/ignoredtests.txt)
set(CTEST_NOTES_FILES ${CTEST_BINARY_DIRECTORY}/ignoredtests.txt)

#--------------------------------------------------------------------------
ctest_build(BUILD ${CTEST_BINARY_DIRECTORY} APPEND)
ctest_submit()

#---Set the environment---------------------------------------------------
set(ENV{ROOTSYS} ${CTEST_BINARY_DIRECTORY})
set(ENV{PATH} ${CTEST_BINARY_DIRECTORY}/bin:$ENV{PATH})
if(APPLE)
  set(ENV{DYLD_LIBRARY_PATH} ${CTEST_BINARY_DIRECTORY}/lib:$ENV{DYLD_LIBRARY_PATH})
elseif(UNIX)
  set(ENV{LD_LIBRARY_PATH} ${CTEST_BINARY_DIRECTORY}/lib:$ENV{LD_LIBRARY_PATH})
endif()
set(ENV{PYTHONPATH} ${CTEST_BINARY_DIRECTORY}/lib:$ENV{PAYTHONPATH})
#---Confgure and run the tests--------------------------------------------
unset(CTEST_CONFIGURE_COMMAND)                  # use now the default
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
file(MAKE_DIRECTORY ${CTEST_BINARY_DIRECTORY}/runtests)

ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}/runtests
                SOURCE  ${CTEST_SOURCE_DIRECTORY}/tutorials
                OPTIONS -DCMAKE_MODULE_PATH=${CTEST_SOURCE_DIRECTORY}/etc/cmake
                APPEND)
ctest_test(BUILD ${CTEST_BINARY_DIRECTORY}/runtests
           PARALLEL_LEVEL ${ncpu}
           APPEND)
ctest_submit()


