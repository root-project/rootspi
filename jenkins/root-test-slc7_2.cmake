#---Common Setting----------------------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/rootCommon.cmake)
set(CTEST_BUILD_NAME ${CTEST_VERSION}-${tag}${Type$ENV{BUILDTYPE}}-slc7)

#---CTest commands----------------------------------------------------------
ctest_start(${CTEST_MODE})

#---Read custom files and generate a note with ignored tests----------------
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
WRITE_INGNORED_TESTS(${CTEST_BINARY_DIRECTORY}/ignoredtests.txt)
set(CTEST_NOTES_FILES ${CTEST_BINARY_DIRECTORY}/ignoredtests.txt)

#---Confgure and run the tests--------------------------------------------
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
file(MAKE_DIRECTORY ${CTEST_BINARY_DIRECTORY}/runtests)

ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}/runtests
                SOURCE  $ENV{ROOTSYS}/tutorials)


ctest_test(BUILD ${CTEST_BINARY_DIRECTORY}/runtests
           PARALLEL_LEVEL ${ncpu})

ctest_submit(PARTS Test Notes)


