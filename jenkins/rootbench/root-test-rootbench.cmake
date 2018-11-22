#---Common Settings-------------------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/rootCommon.cmake)
unset(CTEST_CHECKOUT_COMMAND)  # We do not need to checkout

#---Read custom files and generate a note with ignored tests----------------
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
WRITE_INGNORED_TESTS(ignoredtests.txt)
set(CTEST_NOTES_FILES  ignoredtests.txt)
#--------------------------------------------------------------------------

#----Continuous-----------------------------------------------------------
if(CTEST_MODE STREQUAL continuous)
  ctest_start (Continuous TRACK Continuous-${CTEST_VERSION} APPEND)
  ctest_test(PARALLEL_LEVEL ${ncpu} EXCLUDE "^tutorial-" EXCLUDE_LABEL "benchmark")

#----Install mode---------------------------------------------------------
elseif(CTEST_MODE STREQUAL install)
  get_filename_component(CTEST_BINARY_DIRECTORY runtests ABSOLUTE)
  ctest_start(${CTEST_MODE} TRACK Install)
  #---Set the environment---------------------------------------------------
  set(ENV{PATH} ${CTEST_INSTALL_DIRECTORY}/bin:$ENV{PATH})
  if(APPLE)
    set(ENV{DYLD_LIBRARY_PATH} ${CTEST_INSTALL_DIRECTORY}/lib/root:$ENV{DYLD_LIBRARY_PATH})
  elseif(UNIX)
    set(ENV{LD_LIBRARY_PATH} ${CTEST_INSTALL_DIRECTORY}/lib/root:$ENV{LD_LIBRARY_PATH})
  endif()
  set(ENV{PYTHONPATH} ${CTEST_INSTALL_DIRECTORY}/lib/root:$ENV{PAYTHONPATH})

  #---Configure and run the tests--------------------------------------------
  ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}/tutorials
                  SOURCE  ${CTEST_INSTALL_DIRECTORY}/share/doc/root/tutorials)
  ctest_test(BUILD ${CTEST_RUNTESTS_DIRECTORY}/tutorials PARALLEL_LEVEL ${ncpu} EXCLUDE_LABEL "benchmark")

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
             PARALLEL_LEVEL ${ncpu} EXCLUDE_LABEL "benchmark")

#---Pullrequest mode--------------------------------------------------------
elseif(CTEST_MODE STREQUAL pullrequests)
  ctest_start(Pullrequests TRACK Pullrequests APPEND)
  string(TOLOWER "$ENV{ExtraCMakeOptions}" EXTRA_CMAKE_OPTS_LOWER)
  if(${EXTRA_CMAKE_OPTS_LOWER} MATCHES "dctest_test_exclude_none=on")
    ctest_test(PARALLEL_LEVEL ${ncpu})
  else()
    ctest_test(PARALLEL_LEVEL ${ncpu} EXCLUDE "^tutorial-" EXCLUDE_LABEL "longtest")
  endif()

  # We are done, switch to master to clean up the created branch.
  set(LOCAL_BRANCH_NAME "$ENV{ghprbPullAuthorLogin}-$ENV{ghprbSourceBranch}")
  cleanup_pr_area($ENV{ghprbTargetBranch} ${LOCAL_BRANCH_NAME} ${REBASE_WORKING_DIR})

#---Experimental/Nightly----------------------------------------------------
else()
  ctest_start(${CTEST_MODE} APPEND)
  ctest_test(PARALLEL_LEVEL ${ncpu} EXCLUDE_LABEL "benchmark")
endif()

ctest_submit(PARTS Test Notes)
