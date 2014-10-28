#---Common Setting----------------------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/rootCommon.cmake)

set(CTEST_BUILD_NAME ${CTEST_VERSION}-${tag}${Type$ENV{BUILDTYPE}}-classic)

#--Customize to GNU make build commands--------------------------------------

set(CTEST_CONFIGURE_COMMAND "${CTEST_SOURCE_DIRECTORY}/configure --all")
set(CTEST_BUILD_COMMAND "make -s -i -j${ncpu}")

if(EXISTS "${CTEST_BINARY_DIRECTORY}")
  file(REMOVE_RECURSE ${CTEST_BINARY_DIRECTORY})
endif()

#---Configure tests. Some of them require some files to be copied-----------
file(MAKE_DIRECTORY ${CTEST_BINARY_DIRECTORY})
configure_file(${CTEST_SOURCE_DIRECTORY}/cmake/modules/CTestCustom.cmake ${CTEST_BINARY_DIRECTORY} COPYONLY)

#---CTest commands----------------------------------------------------------
ctest_start(${CTEST_MODE})
ctest_update(SOURCE ${CTEST_SOURCE_DIRECTORY})
ctest_configure(BUILD ${CTEST_BINARY_DIRECTORY})
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build(BUILD ${CTEST_BINARY_DIRECTORY})

ctest_submit(PARTS Update Configure Build)

