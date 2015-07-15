#---Common Setting----------------------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/rootCommon.cmake)

set(CTEST_CHECKOUT_COMMAND)
set(CTEST_BUILD_NAME ${CTEST_VERSION}-${tag}${Type$ENV{BUILDTYPE}}-slc7)
set(RUN_TESTS_DIR ${CTEST_BINARY_DIRECTORY}/runtests)
set(RUN_TESTS_DIR_ROOTTEST ${CTEST_BINARY_DIRECTORY}/runtests-roottest)
set(TESTS_RESULTS_DIR ${CTEST_BINARY_DIRECTORY}/Testing)

#---Clean the directory where the tests results are-----------------------------
if(EXISTS "${TESTS_RESULTS_DIR}")
   file(REMOVE_RECURSE ${TESTS_RESULTS_DIR})
endif()
if(EXISTS "${RUN_TESTS_DIR_ROOTTEST}")
  file(REMOVE_RECURSE ${RUN_TESTS_DIR_ROOTTEST})
endif()

#---Clean the directory whe test------------------------------------------------
if(EXISTS "${RUN_TESTS_DIR}")
  file(REMOVE_RECURSE ${RUN_TESTS_DIR})
endif()

#---CTest commands----------------------------------------------------------
ctest_start(${CTEST_MODE} roottest)

#---For the tutorials--------------------------------------------
file(MAKE_DIRECTORY ${RUN_TESTS_DIR})
ctest_configure(BUILD ${RUN_TESTS_DIR}
                SOURCE $ENV{ROOTSYS}/tutorials)

ctest_build(BUILD ${RUN_TESTS_DIR})

ctest_test(BUILD ${RUN_TESTS_DIR}
           PARALLEL_LEVEL ${ncpu})

ctest_submit(PARTS Configure Build Test Notes)

#---For the roottest--------------------------------------------
file(MAKE_DIRECTORY ${RUN_TESTS_DIR_ROOTTEST})
ctest_configure(BUILD   ${RUN_TESTS_DIR_ROOTTEST}
                APPEND
                SOURCE  roottest)

list(APPEND CTEST_CUSTOM_TESTS_IGNORE
            roottest-cling-parsing-semicolon
            html-runMakeIndex
            tutorial-tree-staff
            tutorial-tree-cernstaff
            tutorial-hist-hbars)

ctest_test(BUILD ${RUN_TESTS_DIR_ROOTTEST}
           APPEND
           PARALLEL_LEVEL ${ncpu})

ctest_submit(PARTS Configure Test)



