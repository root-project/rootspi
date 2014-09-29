#---Common Setting----------------------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/rootCommon.cmake)

#---Enable roottest---------------------------------------------------------
if(CTEST_VERSION STREQUAL "master" OR CTEST_VERSION STREQUAL "v6-02-00-patches")
  set(testing_options "-Droottest=ON")
elseif(CTEST_VERSION STREQUAL "v5-34-00-patches")
  set(testing_options "-Dvc=OFF")
endif()

#---CTest commands----------------------------------------------------------
if(CTEST_MODE STREQUAL continuous)

  #----Continuous-----------------------------------------------------------
  set(CTEST_START_WITH_EMPTY_BINARY_DIRECTORY_ONCE 1)
  #ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
  ctest_start (Continuous TRACK Continuous-${CTEST_VERSION})
  #ctest_update(RETURN_VALUE updates)
  ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}
                  SOURCE  ${CTEST_SOURCE_DIRECTORY}
                  OPTIONS "-Dall=ON;-Dtesting=ON;${testing_options};-DCMAKE_INSTALL_PREFIX=${CTEST_BINARY_DIRECTORY}/install$ENV{ExtraCMakeOptions}")
  #---Read custom files and generate a note with ignored tests----------------
  ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
  WRITE_INGNORED_TESTS(${CTEST_BINARY_DIRECTORY}/ignoredtests.txt)
  set(CTEST_NOTES_FILES  ${CTEST_BINARY_DIRECTORY}/ignoredtests.txt)
  #--------------------------------------------------------------------------
  ctest_build(BUILD ${CTEST_BINARY_DIRECTORY})
  ctest_test(PARALLEL_LEVEL ${ncpu})
  ctest_submit()

elseif(CTEST_MODE STREQUAL install)

  #---Install---------------------------------------------------------------
  ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
  ctest_start(${CTEST_MODE} TRACK Install)
  ctest_update()
  ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}
                  SOURCE  ${CTEST_SOURCE_DIRECTORY}
                  OPTIONS "-Dall=ON;-DCMAKE_INSTALL_PREFIX=${CTEST_BINARY_DIRECTORY}/install$ENV{ExtraCMakeOptions}"
                  APPEND)
  #---Read custom files and generate a note with ignored tests--------------
  ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
  WRITE_INGNORED_TESTS(${CTEST_BINARY_DIRECTORY}/ignoredtests.txt)
  set(CTEST_NOTES_FILES  ${CTEST_BINARY_DIRECTORY}/ignoredtests.txt)
  #-------------------------------------------------------------------------
  ctest_build(BUILD ${CTEST_BINARY_DIRECTORY} TARGET package APPEND)
  #--Untar the installtion kit----------------------------------------------
  file(GLOB tarfile ${CTEST_BINARY_DIRECTORY}/root_*.tar.gz)
  execute_process(COMMAND cmake -E tar xfz ${tarfile} WORKING_DIRECTORY ${CTEST_BINARY_DIRECTORY})
  set(installdir ${CTEST_BINARY_DIRECTORY}/root)
  #---Set the environment---------------------------------------------------
  set(ENV{ROOTSYS} ${installdir})
  set(ENV{PATH} ${installdir}/bin:$ENV{PATH})
  if(APPLE)
    set(ENV{DYLD_LIBRARY_PATH} ${installdir}/lib:$ENV{DYLD_LIBRARY_PATH})
  elseif(UNIX)
    set(ENV{LD_LIBRARY_PATH} ${installdir}/lib:$ENV{LD_LIBRARY_PATH})
  endif()
  set(ENV{PYTHONPATH} ${installdir}/lib:$ENV{PAYTHONPATH})

  #---Confgure and run the tests--------------------------------------------
  file(MAKE_DIRECTORY ${CTEST_BINARY_DIRECTORY}/runtests)
  ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}/runtests
                  SOURCE  ${CTEST_SOURCE_DIRECTORY}/tutorials
                  OPTIONS -DCMAKE_PREFIX_PATH=${installdir}
                  APPEND)
  ctest_test(BUILD ${CTEST_BINARY_DIRECTORY}/runtests
             PARALLEL_LEVEL ${ncpu}
             APPEND)
  ctest_submit()
else()

  #---Experimental------------------------------------------------------------
  ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
  ctest_start(${CTEST_MODE})
  #ctest_update(SOURCE ${CTEST_SOURCE_DIRECTORY})
  ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}
                  SOURCE  ${CTEST_SOURCE_DIRECTORY}
                  OPTIONS "-Dall=ON;-Dtesting=ON;${testing_options};-DCTEST_USE_LAUNCHERS=${CTEST_USE_LAUNCHERS};-DCMAKE_INSTALL_PREFIX=${CTEST_BINARY_DIRECTORY}/install$ENV{ExtraCMakeOptions}")
  #---Read custom files and generate a note with ignored tests----------------
  ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
  WRITE_INGNORED_TESTS(${CTEST_BINARY_DIRECTORY}/ignoredtests.txt)
  set(CTEST_NOTES_FILES  ${CTEST_BINARY_DIRECTORY}/ignoredtests.txt)
  #--------------------------------------------------------------------------
  ctest_build(BUILD ${CTEST_BINARY_DIRECTORY})
  ctest_test(PARALLEL_LEVEL ${ncpu})
  ctest_submit()
endif()

