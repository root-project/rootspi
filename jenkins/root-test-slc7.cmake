#---Common Setting----------------------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/rootCommon.cmake)

set(CTEST_CHECKOUT_COMMAND "cmake -E chdir roottest ${CTEST_GIT_COMMAND} checkout -f $ENV{GIT_PREVIOUS_COMMIT}")
set(CTEST_GIT_UPDATE_CUSTOM  ${CTEST_GIT_COMMAND} checkout -f $ENV{GIT_COMMIT})

get_filename_component(CTEST_SOURCE_DIRECTORY roottest ABSOLUTE)
get_filename_component(CTEST_BINARY_DIRECTORY . ABSOLUTE)

set(CTEST_BUILD_NAME ${CTEST_VERSION}-${tag}${Type$ENV{BUILDTYPE}}-slc7)
set(RUN_TESTS_DIR_TUTORIALS ${CTEST_BINARY_DIRECTORY}/runtests-tutorials)
set(RUN_TESTS_DIR_ROOTTEST  ${CTEST_BINARY_DIRECTORY}/runtests-roottest)
set(TESTS_RESULTS_DIR ${CTEST_BINARY_DIRECTORY}/Testing)

#---Clean the directory where the tests results are-----------------------------
if(EXISTS "${TESTS_RESULTS_DIR}")
   file(REMOVE_RECURSE ${TESTS_RESULTS_DIR})
endif()

if(EXISTS "${RUN_TESTS_DIR_ROOTTEST}")
  file(REMOVE_RECURSE ${RUN_TESTS_DIR_ROOTTEST})
endif()

#---Clean roottest sources------------------------------------------------------
execute_process(COMMAND cmake -E chdir roottest ${CTEST_GIT_COMMAND} clean -xfdq)

#---Clean the directory whe test------------------------------------------------
if(EXISTS "${RUN_TESTS_DIR_TUTORIALS}")
  file(REMOVE_RECURSE ${RUN_TESTS_DIR_TUTORIALS})
endif()

#---CTest commands----------------------------------------------------------
ctest_start(${CTEST_MODE})
ctest_update()

#---For the tutorials--------------------------------------------
file(MAKE_DIRECTORY ${RUN_TESTS_DIR_TUTORIALS})
ctest_configure(BUILD ${RUN_TESTS_DIR_TUTORIALS}
                SOURCE $ENV{ROOTSYS}/tutorials)

ctest_build(BUILD ${RUN_TESTS_DIR_TUTORIALS})

ctest_test(BUILD ${RUN_TESTS_DIR_TUTORIALS}
           PARALLEL_LEVEL ${ncpu})

# TODO: uncomment next line if CDASH will be back
#ctest_submit(PARTS Update Configure Build Test Notes)

#---For the roottest--------------------------------------------
file(MAKE_DIRECTORY ${RUN_TESTS_DIR_ROOTTEST})
ctest_configure(BUILD   ${RUN_TESTS_DIR_ROOTTEST}
                APPEND
                SOURCE  roottest)

list(APPEND CTEST_CUSTOM_TESTS_IGNORE
            roottest-cling-parsing-semicolon
            roottest-root-html-runMakeIndex
            tutorial-tree-staff
            tutorial-tree-cernstaff
            tutorial-hist-hbars)

ctest_test(BUILD ${RUN_TESTS_DIR_ROOTTEST}
           APPEND
           PARALLEL_LEVEL ${ncpu})

# TODO: uncomment next line if CDASH will be back
#ctest_submit(PARTS Configure Test)



