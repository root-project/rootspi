#---Common Setting----------------------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/rootCommon.cmake)

#---Enable roottest---------------------------------------------------------
if(CTEST_VERSION STREQUAL "master" OR CTEST_VERSION MATCHES "^v6-")
  set(testing_options "-Droottest=ON")
endif()

#---Set TCMalloc for fast builds--------------------------------------------
if(CTEST_BUILD_CONFIGURATION STREQUAL "Optimized")
  set(testing_options ${testing_options}" -Dtcmalloc=ON")
endif()

#---Compose the confguration options---------------------------------------- 
set(options -Dall=ON
            -Dtesting=ON
            ${testing_options}
            -DCMAKE_INSTALL_PREFIX=${CTEST_INSTALL_DIRECTORY}
            $ENV{ExtraCMakeOptions})
 
if("$ENV{BUILDOPTS}" STREQUAL "cxx14root7")
  set(options ${options} -Dcxx14=ON -Droot7=ON)
endif()

separate_arguments(options)

#----Continuous-----------------------------------------------------------
if(CTEST_MODE STREQUAL continuous)
  set(empty $ENV{EMPTY_BINARY})
  if(empty)
    ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
  else()
    file(GLOB testruns ${CTEST_BINARY_DIRECTORY}/Testing/*-*)
    if(testruns)
      file(REMOVE_RECURSE ${testruns})
    endif()
  endif()
  ctest_start (Continuous TRACK Continuous-${CTEST_VERSION})
  ctest_update(RETURN_VALUE updates)
  ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}
                  SOURCE  ${CTEST_SOURCE_DIRECTORY}
                  OPTIONS "${options}")
  ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
  ctest_build(BUILD ${CTEST_BINARY_DIRECTORY})
  ctest_submit(PARTS Update Configure Build)

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
  ctest_build(BUILD ${CTEST_BINARY_DIRECTORY} TARGET install APPEND)
  ctest_submit(PARTS Update Configure Build)
  ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})

#---Package---------------------------------------------------------------
elseif(CTEST_MODE STREQUAL package)

  ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
  ctest_start(${CTEST_MODE} TRACK Package)
  ctest_update()
  ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}
                  SOURCE  ${CTEST_SOURCE_DIRECTORY}
                  OPTIONS "${options}"
                  APPEND)
  ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
  ctest_build(BUILD ${CTEST_BINARY_DIRECTORY} TARGET package APPEND)
  ctest_submit(PARTS Update Configure Build)

#----Pullrequests-----------------------------------------------------------
elseif(CTEST_MODE STREQUAL pullrequests)
  set(empty $ENV{EMPTY_BINARY})
  ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
  file(REMOVE_RECURSE ${testruns})

  set(CTEST_CHECKOUT_COMMAND "${CTEST_SCRIPT_DIRECTORY}/pr-reset.sh ${CTEST_SOURCE_DIRECTORY} ${CTEST_GIT_COMMAND}")
  set(CTEST_GIT_UPDATE_CUSTOM  ${CTEST_GIT_COMMAND} checkout -f $ENV{GIT_COMMIT})

  ctest_start (Pullrequests TRACK Pullrequests)
  ctest_update(RETURN_VALUE updates)
  ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}
                  SOURCE  ${CTEST_SOURCE_DIRECTORY}
                  OPTIONS "${options}")
  ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
  ctest_build(BUILD ${CTEST_BINARY_DIRECTORY})
  ctest_submit(PARTS Update Configure Build)

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
  ctest_submit(PARTS Update Configure Build)
endif()


