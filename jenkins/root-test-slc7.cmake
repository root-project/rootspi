#---Common Setting----------------------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/rootCommon.cmake)
set(CTEST_BUILD_NAME ${CTEST_VERSION}-${tag}${Type$ENV{BUILDTYPE}}-slc7)

#---CTest commands----------------------------------------------------------
ctest_start(${CTEST_MODE} APPEND)

#---Read custom files and generate a note with ignored tests----------------
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
WRITE_INGNORED_TESTS(${CTEST_BINARY_DIRECTORY}/ignoredtests.txt)
set(CTEST_NOTES_FILES ${CTEST_BINARY_DIRECTORY}/ignoredtests.txt)

#---Set the environment---------------------------------------------------
#set(ENV{ROOTSYS} ${CTEST_BINARY_DIRECTORY})
#set(ENV{PATH} ${CTEST_BINARY_DIRECTORY}/bin:$ENV{PATH})
#if(APPLE)
#  set(ENV{DYLD_LIBRARY_PATH} ${CTEST_BINARY_DIRECTORY}/lib:$ENV{DYLD_LIBRARY_PATH})
#elseif(UNIX)
#  set(ENV{LD_LIBRARY_PATH} ${CTEST_BINARY_DIRECTORY}/lib:$ENV{LD_LIBRARY_PATH})
#endif()
#set(ENV{PYTHONPATH} ${CTEST_BINARY_DIRECTORY}/lib:$ENV{PAYTHONPATH})

#---Confgure and run the tests--------------------------------------------
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
file(MAKE_DIRECTORY ${CTEST_BINARY_DIRECTORY}/runtests)

message("hhhhhhhhhhhhhhh: ${CTEST_BINARY_DIRECTORY}")

ctest_configure(BUILD    ${CTEST_BINARY_DIRECTORY}/runtests
                SOURCE   ${CTEST_BINARY_DIRECTORY}/../roottest
#		 SOURCE  ${CTEST_BINARY_DIRECTORY}/tutorials
                OPTIONS -DCMAKE_MODULE_PATH=$ENV{ROOTSYS}/etc/cmake)

ctest_test(BUILD ${CTEST_BINARY_DIRECTORY}/runtests
           PARALLEL_LEVEL ${ncpu})

ctest_submit(PARTS Test Notes)


