#---Common Settings-------------------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/rootCommon.cmake)
unset(CTEST_CHECKOUT_COMMAND)  # We do not need to checkout

#---Read custom files and generate a note with ignored tests----------------
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
WRITE_INGNORED_TESTS(${CTEST_BINARY_DIRECTORY}/ignoredtests.txt)
set(CTEST_NOTES_FILES  ${CTEST_BINARY_DIRECTORY}/ignoredtests.txt)
#--------------------------------------------------------------------------

#----Continuous-----------------------------------------------------------
if(CTEST_MODE STREQUAL continuous)
  ctest_start (Continuous TRACK Continuous-${CTEST_VERSION} APPEND)
  ctest_test(PARALLEL_LEVEL ${ncpu} EXCLUDE "^tutorial-")

#----Install mode---------------------------------------------------------
elseif(CTEST_MODE STREQUAL install)
  ctest_start(${CTEST_MODE} TRACK Install APPEND)
  #---Set the environment---------------------------------------------------
  set(ENV{PATH} ${CTEST_INSTALL_DIRECTORY}/bin:$ENV{PATH})
  if(APPLE)
    set(ENV{DYLD_LIBRARY_PATH} ${CTEST_INSTALL_DIRECTORY}/lib/root:$ENV{DYLD_LIBRARY_PATH})
  elseif(UNIX)
    set(ENV{LD_LIBRARY_PATH} ${CTEST_INSTALL_DIRECTORY}/lib/root:$ENV{LD_LIBRARY_PATH})
  endif()
  set(ENV{PYTHONPATH} ${CTEST_INSTALL_DIRECTORY}/lib/root:$ENV{PAYTHONPATH})

  #---Configure and run the tests--------------------------------------------
  get_filename_component(CTEST_RUNTESTS_DIRECTORY runtests ABSOLUTE)
  ctest_configure(BUILD   ${CTEST_RUNTESTS_DIRECTORY}/tutorials
                  SOURCE  ${CTEST_INSTALL_DIRECTORY}/tutorials)
  ctest_test(BUILD ${CTEST_RUNTESTS_DIRECTORY}/tutorials PARALLEL_LEVEL ${ncpu})

#----Package mode---------------------------------------------------------
elseif(CTEST_MODE STREQUAL package)
  ctest_start(${CTEST_MODE} TRACK Package APPEND)
  #--Untar the installation kit----------------------------------------------
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
  #---Configure and run the tests--------------------------------------------
  file(MAKE_DIRECTORY ${CTEST_BINARY_DIRECTORY}/runtests)
  ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}/runtests
                  SOURCE  ${CTEST_SOURCE_DIRECTORY}/tutorials)
  ctest_test(BUILD ${CTEST_BINARY_DIRECTORY}/runtests
             PARALLEL_LEVEL ${ncpu})

#---Experimental/Nightly----------------------------------------------------
else()
  ctest_start(${CTEST_MODE} APPEND)
  ctest_test(PARALLEL_LEVEL ${ncpu})
endif()


ctest_submit(PARTS Test Notes)


