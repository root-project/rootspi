#---Common Setting----------------------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/rootCommon.cmake)

#---Enable roottest---------------------------------------------------------
if(CTEST_VERSION STREQUAL "master" OR CTEST_VERSION STREQUAL "v6-02-00-patches")
  set(testing_options "-Droottest=ON")
endif()

set(options -Dall=ON
            -Dtesting=ON
            ${testing_options}
            -DCMAKE_INSTALL_PREFIX=${CTEST_BINARY_DIRECTORY}/install
            $ENV{ExtraCMakeOptions})
separate_arguments(options)

#----Continuous-----------------------------------------------------------
if(CTEST_MODE STREQUAL continuous)
  file(GLOB testruns ${CTEST_BINARY_DIRECTORY}/Testing/*-*)
  if(testruns)
    file(REMOVE_RECURSE ${testruns})
  endif()
  ctest_start (Continuous TRACK Continuous-${CTEST_VERSION})
  ctest_update(RETURN_VALUE updates)
  ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}
                  SOURCE  ${CTEST_SOURCE_DIRECTORY}
                  OPTIONS "${options}")
  ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
  ctest_build(BUILD ${CTEST_BINARY_DIRECTORY})

#---Install---------------------------------------------------------------
elseif(CTEST_MODE STREQUAL install)

  ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
  ctest_start(${CTEST_MODE} TRACK Install)
  ctest_update()
  ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}
                  SOURCE  ${CTEST_SOURCE_DIRECTORY}
                  OPTIONS "${options}"
                  APPEND)
  ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
  ctest_build(BUILD ${CTEST_BINARY_DIRECTORY} TARGET package APPEND)

#---Experimental/Nightly----------------------------------------------------
else()

  ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
  ctest_start(${CTEST_MODE})
  ctest_update(SOURCE ${CTEST_SOURCE_DIRECTORY})
  ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}
                  SOURCE  ${CTEST_SOURCE_DIRECTORY}
                  OPTIONS "${options}")
  ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
  ctest_build(BUILD ${CTEST_BINARY_DIRECTORY})

endif()

ctest_submit(PARTS Update Configure Build)


