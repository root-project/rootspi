#---Common Settings----------------------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/rootCommon.cmake)

#---CTest commands----------------------------------------------------------
#ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
ctest_start(${CTEST_MODE})
ctest_update()
ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}
                SOURCE  ${CTEST_SOURCE_DIRECTORY}
                OPTIONS "-Dall=ON;-DCMAKE_INSTALL_PREFIX=${CTEST_BINARY_DIRECTORY}/install$ENV{ExtraCMakeOptions}"
                APPEND)
ctest_build(BUILD ${CTEST_BINARY_DIRECTORY} TARGET package
            APPEND)

#--Untar the installtion kit-------------------------------------------------
file(GLOB tarfile ${CTEST_BINARY_DIRECTORY}/root_*.tar.gz)
execute_process(COMMAND cmake -E tar xfz ${tarfile} WORKING_DIRECTORY ${CTEST_BINARY_DIRECTORY})
string(REPLACE ".tar.gz" "" installdir ${tarfile})

#---Set the environment------------------------------------------------------
set(ENV{ROOTSYS} ${installdir})
set(ENV{PATH} ${installdir}/bin:$ENV{PATH})
if(APPLE)
  set(ENV{DYLD_LIBRARY_PATH} ${installdir}/lib:$ENV{DYLD_LIBRARY_PATH})
elseif(UNIX)
  set(ENV{LD_LIBRARY_PATH} ${installdir}/lib:$ENV{LD_LIBRARY_PATH})
endif()  
set(ENV{PYTHONPATH} ${installdir}/lib:$ENV{PAYTHONPATH})

#---Confgure and run the tests-----------------------------------------------
file(MAKE_DIRECTORY ${CTEST_BINARY_DIRECTORY}/runtests)
ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}/runtests
                SOURCE  ${CTEST_SOURCE_DIRECTORY}/tutorials
                APPEND)
ctest_test(BUILD ${CTEST_BINARY_DIRECTORY}/runtests
           PARALLEL_LEVEL ${ncpu}
           APPEND)
ctest_submit()


