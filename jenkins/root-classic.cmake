#---Common Setting----------------------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/rootCommon.cmake)
set(CTEST_BUILD_NAME ${CTEST_VERSION}-${tag}${Type$ENV{BUILDTYPE}}-classic)

#---Build using the classic configure/make ---------------------------------------
file(REMOVE_RECURSE ${CTEST_BINARY_DIRECTORY})
file(MAKE_DIRECTORY ${CTEST_BINARY_DIRECTORY})

set(CTEST_CONFIGURE_COMMAND "${CTEST_SOURCE_DIRECTORY}/configure --all")
set(CTEST_BUILD_COMMAND "make -s -i -j${ncpu}")
configure_file(${CTEST_SOURCE_DIRECTORY}/cmake/modules/CTestCustom.cmake ${CTEST_BINARY_DIRECTORY} COPYONLY)

ctest_start(${CTEST_MODE})
ctest_update(SOURCE ${CTEST_SOURCE_DIRECTORY})
ctest_configure(BUILD ${CTEST_BINARY_DIRECTORY})
ctest_build(BUILD ${CTEST_BINARY_DIRECTORY})
ctest_submit(PARTS Update Configure Build)

unset(CTEST_CHECKOUT_COMMAND)
unset(CTEST_CONFIGURE_COMMAND)
unset(CTEST_BUILD_COMMAND)

#---Checkout rootest--------------------------------------------------------------
#execute_process(COMMAND git rev-parse --abbrev-ref HEAD
#                WORKING_DIRECTORY ${CTEST_SOURCE_DIRECTORY}
#                OUTPUT_VARIABLE GIT_BRANCH OUTPUT_STRIP_TRAILING_WHITESPACE)
#if(GIT_BRANCH STREQUAL HEAD)
#   string(REPLACE "origin/" "" GIT_BRANCH "$ENV{GIT_BRANCH}")  # Comming from Jenkins checkout
#endif()
#   execute_process(COMMAND git clean -xfdq WORKING_DIRECTORY ${CTEST_SOURCE_DIRECTORY}/roottest)
#   execute_process(COMMAND git checkout ${GIT_BRANCH} WORKING_DIRECTORY ${CTEST_SOURCE_DIRECTORY}/roottest)
#   execute_process(COMMAND git fetch origin WORKING_DIRECTORY ${CTEST_SOURCE_DIRECTORY}/roottest)
#   execute_process(COMMAND git rebase origin/${GIT_BRANCH} WORKING_DIRECTORY ${CTEST_SOURCE_DIRECTORY}/roottest)
#else()
#   message("-- Could not find roottest directory! Cloning from the repository...")
#   execute_process(COMMAND git clone -b ${GIT_BRANCH} https://github.com/root-project/roottest.git
#                   WORKING_DIRECTORY ${CTEST_SOURCE_DIRECTORY})
#endif()

#---Setup the environment---------------------------------------------------------
set(ENV{ROOTSYS} ${CTEST_BINARY_DIRECTORY})
set(ENV{PATH} ${CTEST_BINARY_DIRECTORY}/bin:$ENV{PATH})
if(APPLE)
  set(ENV{DYLD_LIBRARY_PATH} ${CTEST_BINARY_DIRECTORY}/lib:$ENV{DYLD_LIBRARY_PATH})
elseif(UNIX)
  set(ENV{LD_LIBRARY_PATH} ${CTEST_BINARY_DIRECTORY}/lib:$ENV{LD_LIBRARY_PATH})
endif()
set(ENV{PYTHONPATH} ${CTEST_BINARY_DIRECTORY}/lib:$ENV{PAYTHONPATH})

#---Run roottest tests -------------------------------------------------------------
#if(EXISTS ${CTEST_SOURCE_DIRECTORY}/roottest/CMakeLists.txt)
#  file(REMOVE_RECURSE ${CTEST_BINARY_DIRECTORY}/roottest)
#  file(MAKE_DIRECTORY ${CTEST_BINARY_DIRECTORY}/roottest)
#
#  ctest_start(${CTEST_MODE} APPEND)
#  ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}/roottest
#                  SOURCE  ${CTEST_SOURCE_DIRECTORY}/../roottest
#                  OPTIONS -DCMAKE_MODULE_PATH=${CTEST_SOURCE_DIRECTORY}/etc/cmake
#                  APPEND)
#  ctest_read_custom_files(${CTEST_BINARY_DIRECTORY}/roottest)
#  ctest_test(BUILD ${CTEST_BINARY_DIRECTORY}/roottest
#             PARALLEL_LEVEL ${ncpu}
#             APPEND)
#  ctest_submit(PARTS Test)
#endif()

#---Run tutorials tests ----------------------------------------------------------
file(REMOVE_RECURSE ${CTEST_BINARY_DIRECTORY}/runtutorials)
file(MAKE_DIRECTORY ${CTEST_BINARY_DIRECTORY}/runtutorials)

ctest_start(${CTEST_MODE} APPEND)
ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}/runtutorials
                SOURCE  ${CTEST_SOURCE_DIRECTORY}/tutorials
                OPTIONS "-DCMAKE_MODULE_PATH=${CTEST_SOURCE_DIRECTORY}/etc/cmake;-DROOT_CLASSIC_BUILD=ON"
                APPEND)
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_test(BUILD ${CTEST_BINARY_DIRECTORY}/runtutorials
           PARALLEL_LEVEL ${ncpu}
           APPEND)
ctest_submit(PARTS Test)

#---Run root tests --------------------------------------------------------------
#file(REMOVE_RECURSE ${CTEST_BINARY_DIRECTORY}/runtests)
#file(MAKE_DIRECTORY ${CTEST_BINARY_DIRECTORY}/runtests)

#ctest_start(${CTEST_MODE} APPEND)
#ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}/runtests
#                SOURCE  ${CTEST_SOURCE_DIRECTORY}/test
#                OPTIONS -DCMAKE_MODULE_PATH=${CTEST_SOURCE_DIRECTORY}/etc/cmake
#                APPEND)
#ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
#ctest_build(BUILD ${CTEST_BINARY_DIRECTORY}/runtests)
#ctest_test(BUILD ${CTEST_BINARY_DIRECTORY}/runtests
#           PARALLEL_LEVEL ${ncpu}
#           APPEND)
#ctest_submit(PARTS Test)





