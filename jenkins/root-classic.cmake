#---Common Setting----------------------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/rootCommon.cmake)

set(CTEST_BUILD_NAME ${CTEST_VERSION}-${tag}${Type$ENV{BUILDTYPE}}-classic)

#--Customize to GNU make build commands--------------------------------------

set(CTEST_CONFIGURE_COMMAND "${CTEST_SOURCE_DIRECTORY}/configure --all")
set(CTEST_BUILD_COMMAND "make -s -i -j${ncpu}")

if (EXIST ${CTEST_BINARY_DIRECTORY})
  file(REMOVE_RECURSE ${CTEST_BINARY_DIRECTORY})
endif()

#---Configure tests. Some of them require some files to be copied-----------
file(MAKE_DIRECTORY ${CTEST_BINARY_DIRECTORY})
configure_file(${CTEST_SOURCE_DIRECTORY}/cmake/modules/CTestCustom.cmake ${CTEST_BINARY_DIRECTORY} COPYONLY)

#---CTest commands----------------------------------------------------------
#ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
ctest_start(${CTEST_MODE})
ctest_update(SOURCE ${CTEST_SOURCE_DIRECTORY})
ctest_configure(BUILD ${CTEST_BINARY_DIRECTORY})

#---Read custom files and generate a note with ignored tests----------------
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
WRITE_INGNORED_TESTS(${CTEST_BINARY_DIRECTORY}/ignoredtests.txt)
set(CTEST_NOTES_FILES ${CTEST_BINARY_DIRECTORY}/ignoredtests.txt)

#--------------------------------------------------------------------------
ctest_build(BUILD ${CTEST_BINARY_DIRECTORY})
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
                OPTIONS -DCMAKE_MODULE_PATH=${CTEST_SOURCE_DIRECTORY}/etc/cmake)
ctest_test(BUILD ${CTEST_BINARY_DIRECTORY}/runtests
           PARALLEL_LEVEL ${ncpu})
ctest_submit(PARTS Test)


