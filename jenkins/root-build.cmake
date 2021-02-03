#---Common Setting----------------------------------------------------------
include(${CTEST_SCRIPT_DIRECTORY}/rootCommon.cmake)

cmake_policy(SET CMP0057 NEW) # interpret the IN_LIST operator
cmake_policy(SET CMP0061 NEW) # do not pass "-i" to GNU make ("continue on error as if success")

set(LABEL "$ENV{LABEL}")

#
# Declare an environment variable in this script and write it to CTestEnvVars.cmake to be loaded
# in the test driver script
#
function(EXPORT_CTEST_ENVVAR VARNAME)
  # This file is loaded (optionally) in root/cmake/modules/CTestCustom.cmake
  file(APPEND ${CTEST_BINARY_DIRECTORY}/CTestEnvVars.cmake "set(ENV{${VARNAME}} TRUE)\n")
  # Also define the variable in this scope to cover possible switches at configuration time
  set(ENV{${VARNAME}} TRUE)
endfunction()

#
#  Initialize ${all_modules} to all available build options.
#
function(GET_ALL_MODULES)
  file(STRINGS "${CTEST_SOURCE_DIRECTORY}/cmake/modules/RootBuildOptions.cmake" ROOTBUILDOPTS)
  foreach(ROOTBUILDOPTSLINE IN LISTS ROOTBUILDOPTS)
    if("${ROOTBUILDOPTSLINE}" MATCHES "^ROOT_BUILD_OPTION")
      set(GITGREP "${GITGREP} ${ROOTBUILDOPTSLINE}")
    endif()
  endforeach()
  if(NOT GITGREP)
    message(FATAL_ERROR "Cannot get configuration options from ${CTEST_SOURCE_DIRECTORY}/cmake/modules/RootBuildOptions.cmake")
  endif()
  string(REGEX MATCHALL
    "ROOT_BUILD_OPTION[(]([^ ]+) "
    all_modules
    "${GITGREP}"
  )
  string(REGEX REPLACE
    "ROOT_BUILD_OPTION[(]([^ ])" "\\1"
    all_modules
    ${all_modules}
  )
  string(REPLACE " " ";" all_modules ${all_modules})

  if("${ROOT_VERSION}" VERSION_GREATER "6.19")
    # These are not *actually* build options. But we want to expose them as such in the CI.
    list(APPEND all_modules
      pyroot2
      pyroot3
    )
  endif()

  # Remove build configuration settings: they are not modules.
  # Remove root7 and webgui because we simply want it on if >= cxx14, i.e. not explicitly steer it.
  list(REMOVE_ITEM all_modules
    builtin_llvm
    builtin_clang
    builtin_cling
    ccache
    cxx11
    cxx14
    cxx17
    cxxmodules
    exceptions
    explicitlink
    gnuinstall
    jemalloc
    macos_native
    memory_termination
    pch
    pyroot_experimental
    root7
    rpath
    runtime_cxxmodules
    shared
    soversion
    tcmalloc
    winrtdebug
    webgui
    coverage
  )
  set(all_modules ${all_modules} PARENT_SCOPE)
endfunction()


#
#  Get all supported modules as ${all_supported}, on Windows.
#  Get all optional builtins as ${package_builtins}.
#
# FIXME: sqlite was disabled to avoid failures in nighlies (compiler error and build configuration issues)
function(GET_ALL_SUPPORTED_MODULES_WIN32)
  set(all_supported
    builtin_afterimage
    builtin_freetype
    builtin_ftgl
    builtin_gl2ps
    builtin_glew
    builtin_lzma
    builtin_lz4
    builtin_pcre
    builtin_xxhash
    builtin_zlib
    builtin_zstd
    asimage
    astiff
    clad
    cling
    dataframe
    fftw3
    gdml
    http
    minuit2
    mlp
    opengl
    pyroot
    pyroot3
    python
    roofit
    spectrum
    table
    thread
    vmc
  )

  set(package_builtins
    builtin_afterimage
    builtin_freetype
    builtin_ftgl
    builtin_gl2ps
    builtin_glew
    builtin_lz4
    builtin_lzma
    builtin_pcre
    builtin_tbb
    builtin_unuran
    builtin_xxhash
    builtin_zlib
  )

  if(ROOT_VERSION VERSION_GREATER 6.15)
    list(APPEND all_supported
      builtin_tbb
      builtin_unuran
      imt
      unuran
    )
  endif()
  if(ROOT_VERSION VERSION_GREATER_EQUAL 6.20)
    list(APPEND all_supported
      builtin_cfitsio
      tmva
    )
  endif()
  if(ROOT_VERSION VERSION_GREATER 6.21 AND ROOT_VERSION VERSION_LESS 6.23)
    list(APPEND all_supported
      pyroot_legacy
    )
  endif()
  if(ROOT_VERSION VERSION_GREATER 6.22)
    list(APPEND all_supported
      builtin_nlohmannjson
      builtin_openui5
    )
  endif()
  set(all_supported ${all_supported} PARENT_SCOPE)
  set(package_builtins ${package_builtins} PARENT_SCOPE)
endfunction()

#
#  Get all supported modules as ${all_supported}, on MacOS.
#  Get all optional builtins as ${package_builtins}.
#
function(GET_ALL_SUPPORTED_MODULES_APPLE)
  set(all_supported
    builtin_afterimage
    builtin_cfitsio
    builtin_davix
    builtin_fftw3
    builtin_freetype
    builtin_ftgl
    builtin_gl2ps
    builtin_glew
    builtin_gsl
    builtin_lzma
    builtin_lz4
    builtin_nlohmannjson
    builtin_openui5
    builtin_openssl
    builtin_pcre
    builtin_tbb
    builtin_unuran
    builtin_vc
    builtin_vdt
    builtin_veccore
    builtin_xrootd
    builtin_xxhash
    builtin_zstd
    asimage
    astiff
    bonjour
    clad
    cling
    cocoa
    dataframe
    davix
    fftw3
    fitsio
    freetype
    ftgl
    gdml
    http
    imt
    krb5
    ldap
    libcxx
    mathmore
    memstat
    minuit2
    mlp
    opengl
    pyroot
    pyroot2
    python
    roofit
    spectrum
    sqlite
    ssl
    table
    thread
    tmva
    tmva-cpu
    tmva-pymva
    unuran
    vdt
    veccore
    vmc
    xml
    xrootd
  )

  if(NOT CTEST_MODE STREQUAL package)
    list(APPEND all_supported
      pyroot3 # Can't release with non-"distro" Python3, but can test
    )
  endif()

  set(package_builtins
    builtin_afterimage
    builtin_cfitsio
    builtin_davix
    builtin_fftw3
    builtin_freetype
    builtin_ftgl
    builtin_gl2ps
    builtin_glew
    builtin_gsl
    builtin_lz4
    builtin_lzma
    builtin_nlohmannjson
    builtin_openui5
    builtin_openssl
    builtin_pcre
    builtin_tbb
    builtin_unuran
    builtin_vc
    builtin_vdt
    builtin_veccore
    builtin_xrootd
    builtin_xxhash
  )

  # Disable Python related tests for Python 2 because that's the Mac OS default Python,
  # which does not allow to install packages. Features related on following Python
  # packages are not tested:
  # - numba
  # - jupyter (notebooks and ROOT C++ kernel)
  EXPORT_CTEST_ENVVAR(ROOTTEST_IGNORE_NUMBA_PY2)
  EXPORT_CTEST_ENVVAR(ROOTTEST_IGNORE_JUPYTER_PY2)

  # We cannot install numba on mac10beta because pip does not yet distribute binaries
  # for llvmlite and building the wheel locally also fails.
  # NOTE: To be removed once the OS is officially released
  if("${LABEL}" MATCHES "mac10beta")
    EXPORT_CTEST_ENVVAR(ROOTTEST_IGNORE_NUMBA_PY3)
  endif()

  set(all_supported ${all_supported} PARENT_SCOPE)
  set(package_builtins ${package_builtins} PARENT_SCOPE)
endfunction()

#
#  Get all supported modules as ${all_supported}, on Linux.
#  Get all optional builtins as ${package_builtins}.
#
function(GET_ALL_SUPPORTED_MODULES_LINUX)
  set(all_supported
    builtin_vdt
    builtin_veccore

    asimage
    astiff
    bonjour
    clad
    cling
    davix
    fftw3
    fitsio
    fortran
    gdml
    gviz
    http
    imt
    krb5
    ldap
    mathmore
    memstat
    minuit2
    mlp
    mysql
    odbc
    opengl
    pgsql
    pyroot
    python
    qt
    qtgsi
    roofit
    shadowpw
    spectrum
    sqlite
    ssl
    table
    thread
    tmva
    tmva-cpu
    tmva-pymva
    unuran
    vdt
    veccore
    vmc
    x11
    xft
    xml
    xrootd
  )

  # Modules that we can only build on selected platforms.
  # Keep this "open ended", i.e. assume that if Ubuntu18 can do it,
  # Ubuntu22 will also be able to do it.

  # clang / gcc ABI issues with i386:
  if (NOT "${LABEL}" MATCHES "-i386")
    list(APPEND all_supported
      dataframe
    )
  endif()

  # For centos7, Rinside uses wrong C++ std (missing abi tag for C++11);
  # Rinside package does not exist for Ubuntu 14.
  if(NOT "${LABEL}" MATCHES "ubuntu14")
    list(APPEND all_supported
      r
      tmva-rmva
    )
  endif()

  if("${LABEL}" MATCHES "fedora|ubuntu" AND
     NOT ("${LABEL}" MATCHES "ubuntu1[46]"))
    # Fedora and Ubuntu 18 and up:
    list(APPEND all_supported
      qt5web
    )
  endif()

  # zstd binaries are too old on Ubuntu 14, 16
  if("${LABEL}" MATCHES "ubuntu1[46]")
    list(APPEND all_supported
      builtin_zstd
    )
  endif()

  # Ubuntu <= 18, Debian10 have a CMake too old for multi-python.
  # Select their default one, python2.
  if(NOT "${LABEL}" MATCHES "ubuntu1[4689]|debian10")
    list(APPEND all_supported
      pyroot3
      )
  endif()

  # Fedora32 and CentOS8 do not have python2 anymore.
  if(NOT "${LABEL}" MATCHES "fedora3[3]|centos8")
    list(APPEND all_supported
      pyroot2
      )
  endif()

  if("${LABEL}" MATCHES "centos")
    list(APPEND all_supported
      castor
      globus
      rfio
    )
  endif()

  if(NOT "${LABEL}" MATCHES "centos|-i386")
    list(APPEND all_supported
      pythia8
    )
  endif()

  if("${LABEL}" MATCHES "fedora27")
    # OpenBlas 3.2 has a bug that causes test failures.
    # Use the generic, slower one from Netlib instead.
    set(ENV{ExtraCMakeOptions} "-DBLA_VENDOR=Generic $ENV{ExtraCMakeOptions}")
  endif()

  # test MPI on Fedora29, 31
  if("${LABEL}" MATCHES "fedora29|fedora31")
    set(ENV{ExtraCMakeOptions} "-DCMAKE_PREFIX_PATH=/usr/lib64/mpich $ENV{ExtraCMakeOptions}")
  endif()

  if("${LABEL}" MATCHES "fedora")
    list(APPEND all_supported
      hdfs
    )
  endif()

  if("${LABEL}" MATCHES "centos|fedora")
    list(APPEND all_supported
      dcache
      gfal
    )
  endif()

  if ("${LABEL}" MATCHES "fedora29")
    list(APPEND all_supported
      mpi
    )
  endif()

  # Vc generates warnings with latest clang HEAD, which are visible in some tests and breaking
  # references.
  if("${LABEL}" MATCHES "fedora|ubuntu" AND
     NOT ("${LABEL}" MATCHES "ubuntu14") AND
     NOT ("${LABEL}" MATCHES "-i386") AND
     NOT ("${LABEL}" MATCHES "ubuntu1804-clangHEAD") AND
     NOT ("${LABEL}" MATCHES "ubuntu2004-clang"))
    # vc needs 64bit, GCC >= 5
    list(APPEND all_supported
      builtin_vc
      vc
    )
  endif()


  # DO NOT use "open ended" matches, i.e. "no Ubuntu supports X".
  # We want to see whether the next Ubuntu version provides a package,
  # and for that we should not treat it special.

  # Apache arrow is installed from their ppa on Ubuntu nodes.
  # It's too new for ROOT 6.16.
  if(ROOT_VERSION VERSION_GREATER 6.17 AND "${LABEL}" MATCHES "ubuntu1[468].04" AND NOT "${LABEL}" MATCHES "-i386")
    list(APPEND all_supported
      arrow
    )
  endif()

  if (ROOT_VERSION VERSION_GREATER 6.14)
    if("${LABEL}" MATCHES "arm64|ppc64|ubuntu1[4689]|fedora2[789]|centos7")
      list(APPEND all_supported
        builtin_tbb
      )
    endif()
  endif()

  if(ROOT_VERSION VERSION_GREATER 6.22)
    list(APPEND all_supported
      builtin_nlohmannjson
      builtin_openui5
    )
  endif()

  if("${LABEL}" MATCHES "ubuntu1[4689]|fedora27|centos7")
    # LZ4 is too old.
    list(APPEND all_supported
      builtin_lz4
    )
  endif()

  if("${LABEL}" MATCHES "ubuntu1[468]")
    # Davix is there but in a Davix version that's broken.
    list(APPEND all_supported
      builtin_davix
    )
  endif()

  if("${LABEL}" MATCHES "ubuntu|debian")
    # Ubuntu has no unuran package.
    list(APPEND all_supported
      builtin_unuran
    )
  endif()

  if("${LABEL}" MATCHES "ubuntu1[468]")
    # Ubuntu < 19.04 has no xxhash.
    list(APPEND all_supported
      builtin_xxhash
    )
  endif()

  if("${LABEL}" MATCHES "ubuntu|debian")
    # Ubuntu has no xrootd
    list(APPEND all_supported
      builtin_xrootd
    )
  endif()

  if("${LABEL}" MATCHES "ubuntu|fedora29|debian")
    list(APPEND all_supported
      builtin_afterimage
    )
  endif()

  # - Ubuntu 18.04 has a system python-numba package which is too old.
  # - Ubuntu 14 has a too old Numpy version from the system that conflicts with installing
  #   numba via pip.
  # - On Ubuntu 16 the installation via pip crashes because of a missing llvmlite for Python 3.5
  # - Newer ones (20 and up) have sufficiently new distro versions.
  if("${LABEL}" MATCHES "ubuntu1[468]")
    EXPORT_CTEST_ENVVAR(ROOTTEST_IGNORE_NUMBA_PY2)
    EXPORT_CTEST_ENVVAR(ROOTTEST_IGNORE_NUMBA_PY3)
  endif()

  # - Jupyter on Ubuntu 14.04 is too old in the distro packages and installing via pip
  #   is also not feasible, e.g., pip3 doesn't work anymore with the system python3 (v3.4)
  # - On Ubuntu 16 the system ipython is too old and does not allow to install metakernel>0.20.0
  if("${LABEL}" MATCHES "ubuntu1[46]")
    EXPORT_CTEST_ENVVAR(ROOTTEST_IGNORE_JUPYTER_PY2)
    EXPORT_CTEST_ENVVAR(ROOTTEST_IGNORE_JUPYTER_PY3)
  endif()

  # Fedora 32 is the dedicated liburing test environment
  if(NOT "${LABEL}" MATCHES "fedora32")
    EXPORT_CTEST_ENVVAR(ROOTTEST_IGNORE_URING)
  endif()

  # Fedora 32 upwards have python2 completely deprecated, also installation of python2-pip is
  # not possible via dnf.
  if("${LABEL}" MATCHES "fedora32|centos8")
    EXPORT_CTEST_ENVVAR(ROOTTEST_IGNORE_NUMBA_PY2)
  endif()

  # numba does not support python 2 on 32 bit (missing llvmlite package)
  if("${LABEL}" MATCHES "-i386")
    EXPORT_CTEST_ENVVAR(ROOTTEST_IGNORE_NUMBA_PY2)
  endif()

  # Do not build builtin_openssl or freetype on Linuxes, rely on distro.
  # Build these below as builtins; use the remaining as shared libs from the distro.
  #
  # On Ubuntu and Fedora, static lz4, lzma, zlib, pcre are built without `-fPIC`
  # and cannot be used to build shared libraries. We expect most users to not
  #  `#include` their headers, so (distro-incompatible) builtins should be fine.
  set(package_builtins
    builtin_afterimage
    builtin_davix
    builtin_ftgl
    builtin_gl2ps
    builtin_glew
    builtin_pcre
    builtin_tbb
    builtin_unuran
    builtin_vdt
    builtin_veccore
    builtin_xrootd
    builtin_xxhash
    builtin_lz4
    builtin_lzma
    builtin_nlohmannjson
    builtin_openui5
    builtin_zlib
  )

  # Don't add builtin_vc if vc is disabled.
  if ("vc" IN_LIST all_supported)
    list(APPEND all_supported
      builtin_vc
    )
  endif()

  list(REMOVE_ITEM package_builtins ${all_supported})

  set(all_supported ${all_supported} PARENT_SCOPE)
  set(package_builtins ${package_builtins} PARENT_SCOPE)
endfunction()


#
#  Get the subset of MODULES that is supported on the current platform.
#  Returns ${supported_modules}.
#
function(FILTER_PLATFORM_SUPPORTED_MODULES MODULES)
  if(WIN32)
    GET_ALL_SUPPORTED_MODULES_WIN32()
  elseif(APPLE)
    GET_ALL_SUPPORTED_MODULES_APPLE()
  else()
    GET_ALL_SUPPORTED_MODULES_LINUX()
  endif()
  message("AXEL: all_supported=${all_supported}")

  # Unsupported modules are those that are in MODULES but not in ${all_supported}
  set(MODULES_UNSUPPORTED ${MODULES})
  list(REMOVE_ITEM MODULES_UNSUPPORTED ${all_supported})
  message("AXEL: MODULES_UNSUPPORTED=${MODULES_UNSUPPORTED}")

  # Supported modules are those in MODULES that are not unsupported.
  list(REMOVE_ITEM MODULES ${MODULES_UNSUPPORTED})
  set(supported_modules ${MODULES} PARENT_SCOPE)
  set(package_builtins ${package_builtins} PARENT_SCOPE)
  message("AXEL: supported_modules=${MODULES}")
  message("AXEL: package_builtins=${package_builtins}")
endfunction()


#
#  Get modules to enable for a nightly or incremental build, if supported
#  on the current platform. Use as many packages from the distro as possible.
#  Returned as ${want_modules}
#
function(GET_MOST_MODULES ALL_MODULES)
  FILTER_PLATFORM_SUPPORTED_MODULES("${ALL_MODULES}")

  set(want_modules ${supported_modules} PARENT_SCOPE)
  set(package_builtins ${package_builtins} PARENT_SCOPE)
endfunction()


#
#  Get modules to enable for a package or pullrequests build, if supported
#  on the current platform. Only important modules will be enabled.
#  Returned as ${want_modules}
#
function(GET_RELEASE_MODULES ALL_MODULES)
  GET_MOST_MODULES("${ALL_MODULES}")

  # Build as stand-alone as possible: add optional builtins.
  list(APPEND want_modules ${package_builtins})

  # We don't want to include these modules in releases:
  list(REMOVE_ITEM want_modules
    afdsmgrd
    alien
    arrow
    bonjour
    castor
    cefweb
    cuda
    dcache
    geocad
    gfal
    globus
    gviz
    hdfs
    krb5
    ldap
    memstat
    monalisa
    odbc
    oracle
    qt
    qt5web
    qtgsi
    r
    rfio
    table
    tmva-gpu
    tmva-rmva
    vecgeom
  )

  set(want_modules ${want_modules} PARENT_SCOPE)
endfunction()


#
#  Remove modules that cannot be built given the SPECLIST.
#
function(REMOVE_SPEC_SUPPRESSED SPECLIST want_modules)
  if("cxx17" IN_LIST SPECLIST AND ${ROOT_VERSION} VERSION_LESS 6.23)
    # builtin_xrootd cannot be built with C++17.
    list(REMOVE_ITEM want_modules
      buildin_xrootd
    )
  endif()
  if("cxxmod" IN_LIST SPECLIST)
    # The module build currently fails to compile gfal and R.
    list(REMOVE_ITEM want_modules
      gfal
    )
    if(APPLE)
      list(REMOVE_ITEM want_modules
        cocoa
        opengl
      )
    endif()
  endif()
  if("python3" IN_LIST SPECLIST)
    # If we force pyroot3 we will not be building pyroot2:
    list(REMOVE_ITEM want_modules
        pyroot2
    )
  endif()
  set(want_modules ${want_modules} PARENT_SCOPE)
endfunction()


#
#  Get modules to enable for this build, on this platform, given the SPECLIST.
#  Return as ${enabled_modules}
#
function(GET_MODULES SPECLIST)
  GET_ALL_MODULES()
  list(SORT all_modules)
  message("AXEL: all modules = ${all_modules}")

  if(CTEST_MODE STREQUAL package OR CTEST_MODE STREQUAL pullrequests)
    GET_RELEASE_MODULES("${all_modules}")
  else()
    GET_MOST_MODULES("${all_modules}")
  endif()


  REMOVE_SPEC_SUPPRESSED("${SPECLIST}" "${want_modules}")
  message("AXEL: modules after removing SPEC suppressed = ${all_modules}")

  set(enabled_modules "")
  foreach(module IN LISTS all_modules)
    list(FIND want_modules ${module} FOUNDIDX)
    if(FOUNDIDX EQUAL -1)
      set(enabled_modules "${enabled_modules} -D${module}=Off")
    else()
      set(enabled_modules "${enabled_modules} -D${module}=On")
    endif()
  endforeach()
  set(enabled_modules ${enabled_modules} PARENT_SCOPE)
endfunction()

#
#  MAIN(), sort of.
#
function(CONFIGURE_ROOT_OPTIONS)

  # First build a list out of spec1-spec2-spec3 for easier matching.
  string(REPLACE "-" ";" SPECLIST "$ENV{SPEC}")

  #---Select modules to enable as ${enabled_modules}--------------------------
  GET_MODULES("${SPECLIST}")
  message("AXEL: ${enabled_modules}")

  #---Enable tests------------------------------------------------------------
  if(NOT CTEST_MODE STREQUAL package)
    set(testing_options "-Dtesting=ON")
    if(CTEST_VERSION STREQUAL "master" OR CTEST_VERSION MATCHES "^v6-")
      if(NOT WIN32)
        set(testing_options "${testing_options} -Droottest=ON")
      elseif(CTEST_VERSION STREQUAL "master" OR ROOT_VERSION VERSION_GREATER_EQUAL 6.23)
        set(testing_options "${testing_options} -Droottest=ON")
      endif()
    endif()

    #---Set TCMalloc for fast builds------------------------------------------
    if(CTEST_BUILD_CONFIGURATION STREQUAL "Optimized")
      set(testing_options ${testing_options}" -Dtcmalloc=ON")
    endif()
  endif()

  #---Use ccache--------------------------------------------------------------
  if((NOT CTEST_MODE STREQUAL package) AND (NOT "${LABEL}" MATCHES "ROOT-performance-centos8-multicore"))
    set(ccache_option "-Dccache=ON")
  endif()

  #---soversion-----------------------------------------------------
  if (ROOT_VERSION VERSION_GREATER 6.14)
    # Releasing with soversion enabled starting v6.16
    if(CTEST_MODE STREQUAL package OR CTEST_MODE STREQUAL pullrequests
       OR "soversion" IN_LIST SPECLIST)
      set(soversion_option "-Dsoversion=On")
    endif()
  endif()

  #---Consider SPEC flags-----------------------------------------------------
  set(specflags "")
  if("python3" IN_LIST SPECLIST)
    find_program(PYTHON3PATH python3)
    if(${PYTHON3PATH} STREQUAL "NOTFOUND")
      message(FATAL_ERROR "Cannot find Python3 for this python3 build!")
    endif()
    set(specflags "${specflags} -DPYTHON_EXECUTABLE=${PYTHON3PATH}")
  endif()

  if("noimt" IN_LIST SPECLIST)
    string(REGEX REPLACE "-Dimt=[^ ]+ ?" "" enabled_modules ${enabled_modules})
    string(REGEX REPLACE "-Dbuiltin_tbb=[^ ]+ ?" "" enabled_modules ${enabled_modules})
    set(specflags "${specflags} -Dimt=Off -Dbuiltin_tbb=Off")
  endif()

  if("nortcxxmod" IN_LIST SPECLIST)
    set(specflags "${specflags} -Druntime_cxxmodules=Off")
  elseif("rtcxxmod" IN_LIST SPECLIST)
    set(specflags "${specflags} -Druntime_cxxmodules=On")
  endif()

  if("cxxmod" IN_LIST SPECLIST)
    set(specflags "${specflags} -Dcxxmodules=On")
    # Enable incremental builds for cxxmodules
    set(ENV{LIBCLANG_DISABLE_PCH_VALIDATION} 1)
  endif()

  if (ROOT_VERSION VERSION_GREATER_EQUAL 6.17)
    if("cxx17" IN_LIST SPECLIST)
      set(specflags ${specflags} -DCMAKE_CXX_STANDARD=17)
    elseif("cxx14" IN_LIST SPECLIST)
      set(specflags ${specflags} -DCMAKE_CXX_STANDARD=14)
    else()
      set(specflags ${specflags} -DCMAKE_CXX_STANDARD=11)
    endif()
  else()
    if("cxx17" IN_LIST SPECLIST)
      set(specflags ${specflags} -Dcxx17=ON)
    elseif("cxx14" IN_LIST SPECLIST)
      set(specflags ${specflags} -Dcxx14=ON)
    else()
      set(specflags ${specflags} -Dcxx11=ON)
    endif()
  endif()

  if("asan" IN_LIST SPECLIST)
    set(specflags ${specflags} -Dasan=ON)
  endif()

  #---CMAKE_BUILD_TYPE--------------------------------------------------------
  set(buildtype_option -DCMAKE_BUILD_TYPE=${CTEST_BUILD_CONFIGURATION})
  if(WIN32)
    set(buildtype_option -A Win32 -Thost=x64 ${buildtype_option})
  endif()

  #---No OS Python3 on MacOS--------------------------------------------------
  if(APPLE AND CTEST_MODE STREQUAL package)
    set(pythonexe_options -DPYTHON_EXECUTABLE=/usr/bin/python)
  endif()

  #---ASSERTS-----------------------------------------------------------------
  if(NOT CTEST_MODE STREQUAL package AND NOT CTEST_BUILD_CONFIGURATION STREQUAL Debug)
    set(asserts_options "-Dasserts=ON -DLLVM_ENABLE_ASSERTIONS=On")
  endif()

  #---Compose the configuration options---------------------------------------
  # Do we want -DCMAKE_VERBOSE_MAKEFILE=ON? Makes builds slow due to text output.
  set(options
    -Wno-deprecated
    -Dfail-on-missing=On
    ${buildtype_option}
    ${enabled_modules}
    ${shared_option}
    ${specflags}
    ${ccache_option}
    ${soversion_option}
    ${testing_options}
    ${pythonexe_options}
    ${asserts_options}
    -DCMAKE_INSTALL_PREFIX=${CTEST_INSTALL_DIRECTORY}
    $ENV{ExtraCMakeOptions}
  )

  separate_arguments(options)
  set(options ${options} PARENT_SCOPE)
endfunction()

#---Configure generator-----------------------------------------------------
if(CTEST_MODE STREQUAL continuous OR CTEST_MODE STREQUAL pullrequests)
  find_program(NINJA_EXECUTABLE ninja)
  if(NINJA_EXECUTABLE)
    if(NOT WIN32)
      set(CTEST_CMAKE_GENERATOR "Ninja")
    endif()
  endif()
endif()

#---Handle cxxmodules and coverity builds' checkout behavior----------------
if("$ENV{BUILDOPTS}" STREQUAL "cxxmodules" OR
   "$ENV{BUILDOPTS}" STREQUAL "coverity")
  unset(CTEST_CHECKOUT_COMMAND)
endif()

#----Continuous-----------------------------------------------------------
if(CTEST_MODE STREQUAL continuous)
  set(empty $ENV{EMPTY_BINARY})
  if(empty)
    #ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
    file(REMOVE_RECURSE ${CTEST_BINARY_DIRECTORY})
  else()
    file(GLOB testruns ${CTEST_BINARY_DIRECTORY}/Testing/*-*)
    if(testruns)
      file(REMOVE_RECURSE ${testruns})
    endif()
  endif()
  ctest_start (Continuous TRACK Incremental)
  ctest_update(RETURN_VALUE updates)

  CONFIGURE_ROOT_OPTIONS()

  if(NOT EXISTS ${CTEST_BINARY_DIRECTORY}/CMakeCache.txt)
    ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}
                    SOURCE  ${CTEST_SOURCE_DIRECTORY}
                    OPTIONS "${options}" RETURN_VALUE status)
    if(NOT ${status} EQUAL 0)
      message(FATAL_ERROR "Failed to configure project")
    endif()
  endif()
  ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
  ctest_build(BUILD ${CTEST_BINARY_DIRECTORY})
  ctest_submit(PARTS Update Configure Build)

#---Install---------------------------------------------------------------
elseif(CTEST_MODE STREQUAL install)

  #ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
  file(REMOVE_RECURSE ${CTEST_BINARY_DIRECTORY})
  ctest_start(${CTEST_MODE} TRACK Install)
  ctest_update()

  CONFIGURE_ROOT_OPTIONS()

  ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}
                  SOURCE  ${CTEST_SOURCE_DIRECTORY}
                  OPTIONS "${options}" APPEND
                  RETURN_VALUE status)
  if(NOT ${status} EQUAL 0)
    message(FATAL_ERROR "Failed to configure project")
  endif()
  ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
  ctest_build(BUILD ${CTEST_BINARY_DIRECTORY} TARGET install APPEND)
  ctest_submit(PARTS Update Configure Build)
  #ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
  file(REMOVE_RECURSE ${CTEST_BINARY_DIRECTORY})

#---Package---------------------------------------------------------------
elseif(CTEST_MODE STREQUAL package)

  #ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
  file(REMOVE_RECURSE ${CTEST_BINARY_DIRECTORY})
  ctest_start(${CTEST_MODE} TRACK Package)
  if (PACKAGE_DATE) # otherwise we have extracted a tar file
    ctest_update()
  endif()

  CONFIGURE_ROOT_OPTIONS()

  ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}
                  SOURCE  ${CTEST_SOURCE_DIRECTORY}
                  OPTIONS "${options}" APPEND
                  RETURN_VALUE status)
  if(NOT ${status} EQUAL 0)
    message(FATAL_ERROR "Failed to configure project")
  endif()
  ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
  ctest_build(BUILD ${CTEST_BINARY_DIRECTORY} TARGET package APPEND)
  ctest_submit(PARTS Update Configure Build)

#----Pullrequests-----------------------------------------------------------
elseif(CTEST_MODE STREQUAL pullrequests)

  cleanup_pr_build_area(${CTEST_BINARY_DIRECTORY})

  # The code semantically does the following:
  # 1. Resets the working area (and checks out the ghprbTargetBranch aka master).
  # 2. git fetch https://github.com/AUTHOR_ID/root.git REMOTE_BRANCH_NAME:LOCAL_BRANCH_NAME
  # 3. git rebase master

  set(REMOTE_BRANCH_NAME "$ENV{ghprbSourceBranch}")
  set(LOCAL_BRANCH_NAME "$ENV{ghprbPullAuthorLogin}-$ENV{ghprbSourceBranch}")

  # Use --git-dir as -C isn't available for old git.
  # FIXME: This can go if we have newer git versions supporting git -C.
  set(GIT_WORKING_DIR "--git-dir=${REBASE_WORKING_DIR}/.git/ --work-tree=${REBASE_WORKING_DIR}")

  # Clean up the area here. If for some reason the rebase screwed up we do not
  # need to wait N times the rest of the cleanup procedures to kick in.
  cleanup_pr_area($ENV{ghprbTargetBranch} ${LOCAL_BRANCH_NAME} ${REBASE_WORKING_DIR})

  execute_process_and_log(COMMAND ${CTEST_GIT_COMMAND} fetch $ENV{ghprbAuthorRepoGitUrl} ${REMOTE_BRANCH_NAME}:${LOCAL_BRANCH_NAME} WORKING_DIRECTORY ${REBASE_WORKING_DIR}
  HINT "Fetching from $ENV{ghprbAuthorRepoGitUrl} branch ${REMOTE_BRANCH_NAME} as ${LOCAL_BRANCH_NAME}")

  # git rebase master LOCAL_BRANCH_NAME rebases the LOCAL_BRANCH_NAME on master and checks out LOCAL_BRANCH_NAME.
  # Note that we cannot rebase against origin/master because sometimes (for an unknown to me reason)
  # origin/master is behind master. It is likely due to the git fetch configuration on the nodes.
  set(ERROR_OCCURRED 0)
  execute_process_and_log(COMMAND  ${CTEST_GIT_COMMAND} -c user.name=sftnight
    -c user.email=sftnight@cern.ch rebase -f -v $ENV{ghprbTargetBranch} ${LOCAL_BRANCH_NAME}
    WORKING_DIRECTORY ${REBASE_WORKING_DIR}
    TIMEOUT 300
    RESULT_VARIABLE ERROR_OCCURRED
    HINT "Rebasing ${LOCAL_BRANCH_NAME} against $ENV{ghprbTargetBranch}"
    )
  if (ERROR_OCCURRED)
    # We are in the error case, switch to master to clean up the created branch.
    cleanup_pr_area($ENV{ghprbTargetBranch} ${LOCAL_BRANCH_NAME} ${REBASE_WORKING_DIR})
    message(FATAL_ERROR "Rebase of ${LOCAL_BRANCH_NAME} branch on top of $ENV{ghprbTargetBranch} failed!")
  endif()

  # A PR can require changes to root.git and roottest.git. Try switching root or roottest
  # (depending if the PR build was triggered from root or roottest repo) to AUTHOR_ID-BRANCH_NAME if
  # we have if. This ensures consistent building and testing.
  set(FETCH_FAILED)

  # Clean up the area of the 'other' repository, too.
  cleanup_pr_area($ENV{ghprbTargetBranch} ${LOCAL_BRANCH_NAME} ${OTHER_REPO_FOR_BRANCH_SYNC_SOURCE_DIR})

  execute_process_and_log(COMMAND ${CTEST_GIT_COMMAND} fetch ${OTHER_REPO_FOR_BRANCH_SYNC_GIT_URL} ${REMOTE_BRANCH_NAME}:${LOCAL_BRANCH_NAME}
    WORKING_DIRECTORY "${OTHER_REPO_FOR_BRANCH_SYNC_SOURCE_DIR}"
    RESULT_VARIABLE FETCH_FAILED
    HINT "Fetching from ${OTHER_REPO_FOR_BRANCH_SYNC_GIT_URL} branch ${REMOTE_BRANCH_NAME} as ${LOCAL_BRANCH_NAME}")

  # If fetch failed this means the user did not have the clone of root/roottest or did not have a branch
  # with the expected name. Ignore and continue.
  if(NOT FETCH_FAILED)
    message("Found remote ${OTHER_REPO_FOR_BRANCH_SYNC_GIT_URL} with corresponding branch name ${REMOTE_BRANCH_NAME}. \
Integrating against it. Please make sure you open and merge a PR against it.")
    # If we have a corresponding branch, check it out and rebase it as we do for above.
    # FIXME: Figure out how to factor out the rebase cmake fragments.
    execute_process_and_log(COMMAND  ${CTEST_GIT_COMMAND} checkout -f $ENV{ghprbTargetBranch}
      WORKING_DIRECTORY ${OTHER_REPO_FOR_BRANCH_SYNC_SOURCE_DIR}
      HINT "Checking out $ENV{ghprbTargetBranch}"
      )
    execute_process_and_log(COMMAND  ${CTEST_GIT_COMMAND} -c user.name=sftnight
      -c user.email=sftnight@cern.ch rebase -f -v $ENV{ghprbTargetBranch} ${LOCAL_BRANCH_NAME}
      WORKING_DIRECTORY ${OTHER_REPO_FOR_BRANCH_SYNC_SOURCE_DIR}
      TIMEOUT 300
      RESULT_VARIABLE ERROR_OCCURRED
      HINT "Rebasing ${LOCAL_BRANCH_NAME} against $ENV{ghprbTargetBranch}"
      )
    if (ERROR_OCCURRED)
      cleanup_pr_area($ENV{ghprbTargetBranch} ${LOCAL_BRANCH_NAME} ${OTHER_REPO_FOR_BRANCH_SYNC_SOURCE_DIR})
      message(FATAL_ERROR "Rebase of ${LOCAL_BRANCH_NAME} branch on top of $ENV{ghprbTargetBranch} in ${WARNING_OTHER_REPO} failed!")
    endif()
  endif()

  ctest_start (Pullrequests TRACK Pullrequests)

  # Note that we cannot use CTEST_GIT_UPDATE_CUSTOM to host our rebase command because cdash will
  # start showing all changes from the PR's HEAD (which can be very old) to current master.
  # In order to workaround this issue we do the rebase outside of the ctest update system. Then,
  # we checkout the master branch and then checkout the already rebased branch. This way we trick
  # ctest_update to pick up only the relevant differences.
  execute_process_and_log(COMMAND  ${CTEST_GIT_COMMAND} checkout -f $ENV{ghprbTargetBranch}
    WORKING_DIRECTORY ${REBASE_WORKING_DIR}
    HINT "Checking out $ENV{ghprbTargetBranch}"
    )

  # Do not put ${CTEST_GIT_COMMAND} checkout ${LOCAL_BRANCH_NAME} in quotes! It breaks ctest_update.
  set(CTEST_GIT_UPDATE_CUSTOM ${CTEST_GIT_COMMAND} checkout ${LOCAL_BRANCH_NAME})
  ctest_update(SOURCE "${REBASE_WORKING_DIR}" RETURN_VALUE updates)

  CONFIGURE_ROOT_OPTIONS()

  if(updates LESS 0) # stop if update error
    # We are in the error case, switch to master to clean up the created branch.
    cleanup_pr_area($ENV{ghprbTargetBranch} ${LOCAL_BRANCH_NAME} ${REBASE_WORKING_DIR})
    ctest_submit(PARTS Update)
    message(FATAL_ERROR "There are no updated files. Perhaps the rebase of ${LOCAL_BRANCH_NAME} branch on top of $ENV{ghprbTargetBranch} failed!")
  endif()
  ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}
                  SOURCE  ${CTEST_SOURCE_DIRECTORY}
                  OPTIONS "${options}" RETURN_VALUE status)
  if(NOT ${status} EQUAL 0)
    message(FATAL_ERROR "Failed to configure project")
  endif()
  ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
  ctest_build(BUILD ${CTEST_BINARY_DIRECTORY})
  ctest_submit(PARTS Update Configure Build)

  # We must not delete the branches here. They are deleted *after* running ctest (in root-test.cmake).


#---Experimental/Nightly----------------------------------------------------
else()

  #ctest_empty_binary_directory(${CTEST_BINARY_DIRECTORY})
  file(REMOVE_RECURSE ${CTEST_BINARY_DIRECTORY})
  ctest_start(${CTEST_MODE})
  ctest_update(SOURCE ${CTEST_SOURCE_DIRECTORY})

  CONFIGURE_ROOT_OPTIONS()

  ctest_configure(BUILD   ${CTEST_BINARY_DIRECTORY}
                  SOURCE  ${CTEST_SOURCE_DIRECTORY}
                  OPTIONS "${options}" RETURN_VALUE status)
  if(NOT ${status} EQUAL 0)
    message(FATAL_ERROR "Failed to configure project")
  endif()
  ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
  ctest_build(BUILD ${CTEST_BINARY_DIRECTORY})
  ctest_submit(PARTS Update Configure Build)
endif()
