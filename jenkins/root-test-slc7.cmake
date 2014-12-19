#---Common Setting----------------------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/rootCommon.cmake)
set(CTEST_BUILD_NAME ${CTEST_VERSION}-${tag}${Type$ENV{BUILDTYPE}}-slc7)
set(RUN_TESTS_DIR ${CTEST_BINARY_DIRECTORY}/runtests)
set(TESTS_RESULTS_DIR ${CTEST_BINARY_DIRECTORY}/../build/Testing)

#---Clean the directory where the tests results are-----------------------------
if(EXISTS "${TESTS_RESULTS_DIR}")
endif()

   file(REMOVE_RECURSE ${RUN_TESTS_DIR})
endif()

#---Clean the directory whe test------------------------------------------------
if(EXISTS "${RUN_TESTS_DIR}")
  file(REMOVE_RECURSE ${RUN_TESTS_DIR})
endif()

#---CTest commands----------------------------------------------------------
ctest_start(${CTEST_MODE})

#---Read custom files and generate a note with ignored tests----------------
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
WRITE_INGNORED_TESTS(${CTEST_BINARY_DIRECTORY}/ignoredtests.txt)
set(CTEST_NOTES_FILES ${CTEST_BINARY_DIRECTORY}/ignoredtests.txt)

#---Confgure and run the tests--------------------------------------------
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
file(MAKE_DIRECTORY ${RUN_TESTS_DIR})

ctest_configure(BUILD ${RUN_TESTS_DIR}
                SOURCE $ENV{ROOTSYS}/tutorials)

ctest_test(BUILD ${RUN_TESTS_DIR}
           PARALLEL_LEVEL ${ncpu})

# ctest_submit(PARTS Test Notes)

# Run roottest also and upload to cdash: EXPERIMENTAL!
# Will cdash accept 2 results uploads and sum them up?
if(EXISTS "${RUN_TESTS_DIR}")
  file(REMOVE_RECURSE ${RUN_TESTS_DIR})
endif()

file(MAKE_DIRECTORY ${RUN_TESTS_DIR}-roottest)
ctest_configure(BUILD   ${RUN_TESTS_DIR}-roottest
                SOURCE  ${CTEST_BINARY_DIRECTORY}/../roottest)

ctest_test(BUILD ${RUN_TESTS_DIR}
           PARALLEL_LEVEL ${ncpu})

ctest_submit(PARTS Test Notes)



