@echo off

echo Execution started: %date% %time%

rem ---Compiler------------------------------------------------------
if %COMPILER% == vc9   call "%VS90COMNTOOLS%vsvars32.bat"
if %COMPILER% == vc10  call "%VS100COMNTOOLS%vsvars32.bat"
if %COMPILER% == vc11  call "%VS110COMNTOOLS%vsvars32.bat"
if %COMPILER% == vc12  call "%VS120COMNTOOLS%vsvars32.bat"
if %COMPILER% == vc13  call "%VS130COMNTOOLS%vsvars32.bat"

rem ---External libraries--------------------------------------------
rem set GSL_DIR=C:\libs\gsl-1.14

rem ---Options-------------------------------------------------------
set THIS=%~d0%~p0
set ExtraCMakeOptions=";-Droofit=ON"

set DEST=root_v%VERSION%

for /f "tokens=7" %%g in ('nmake 2^>^&1 ^| findstr /i /c:" Version "') do (
  set NMAKEVER=%%g
)
for /f "delims=. tokens=1-4" %%v in ("%NMAKEVER%") do (
  set VS_VER=%%v
)
set VC_DIR=vc%VS_VER%

if "%BUILDTYPE%" == "Debug" (
  set DEST=root_v%VERSION%_dbg
)
if "%BUILDTYPE%" == "RelWithDebInfo" (
  set DEST=root_v%VERSION%_dbg
)

if "%SOURCE_PREFIX%" == "" (
  set ROOT_SOURCE_PREFIX=%CD%\sources
) else (
  set ROOT_SOURCE_PREFIX=%SOURCE_PREFIX%
)

if "%BUILD_PREFIX%" == "" (
  set ROOT_BUILD_PREFIX=%CD%
) else (
  set ROOT_BUILD_PREFIX=%BUILD_PREFIX%
)

set SOURCE_DIR=%ROOT_SOURCE_PREFIX%\root_v%VERSION%
set BUILD_DIR=%ROOT_BUILD_PREFIX%\build\Win32-%LABEL%-%COMPILER%\root_v%VERSION%-cmake
set INSTALL_DIR=%ROOT_BUILD_PREFIX%\install\ROOT\%VERSION%\Win32-%LABEL%-%COMPILER%

set DRIVE=%~d0
set HOME_DIR=%CD%
rem set BUILD_DIR=%HOME_DIR%\build\%DEST%
rem set SOURCE_DIR=%HOME_DIR%\source\root_v%VERSION%
rem set INSTALL_DIR=%HOME_DIR%\%DEST%

if not exist %SOURCE_DIR% mkdir %SOURCE_DIR%
cd %SOURCE_DIR%
set TAR_CMD="%ProgramFiles%\7-Zip\7z.exe"
set SRC_TAR_FILE="root_v%VERSION%.source.tar.gz"
if not exist %SRC_TAR_FILE% (
   powershell -NoProfile -Command "(new-object System.Net.WebClient).DownloadFile('http://root.cern.ch/download/%SRC_TAR_FILE%', '%SRC_TAR_FILE%')"
)
if not exist %SOURCE_DIR%\root %TAR_CMD% x %SRC_TAR_FILE% -so | %TAR_CMD% x -aoa -si -ttar

echo Dumping the full environment ---------------------------------------------------------
set
echo --------------------------------------------------------------------------------------

if not exist %BUILD_DIR% mkdir %BUILD_DIR%
cd %BUILD_DIR%

cmake -DCMAKE_BUILD_TYPE=%BUILDTYPE% ^
      -DCMAKE_INSTALL_PREFIX=%INSTALL_DIR%\root ^
      -DCMAKE_VERBOSE_MAKEFILE=ON ^
      -Wno-dev=ON ^
      -Dall=ON ^
      -Dvc=OFF ^
      -Dmathmore=ON ^
      -DGSL_INCLUDE_DIR=%DRIVE%/external/%VC_DIR%/GSL/1.16/include ^
      -DGSL_LIBRARY=%DRIVE%/external/%VC_DIR%/GSL/1.16/lib/Release/gsl.lib ^
      -DGSL_CBLAS_LIBRARY=%DRIVE%/external/%VC_DIR%/GSL/1.16/lib/Release/gslcblas.lib ^
      -Dpythia8=ON ^
      -DPYTHIA8_INCLUDE_DIR=%DRIVE%/external/%VC_DIR%/pythia8/include ^
      -DPYTHIA8_LIBRARY=%DRIVE%/external/%VC_DIR%/pythia8/lib/Release/libPythia8.lib ^
      -DPYTHON_EXECUTABLE=%DRIVE%/external/Python27/python.exe ^
      -DPYTHON_INCLUDE_DIR=%DRIVE%/external/Python27/Include ^
      -DPYTHON_LIBRARY=%DRIVE%/external/Python27/libs/python27.lib ^
      "-GVisual Studio %VS_VER%" %SOURCE_DIR%\root

rem now lets start the build (cmake --build . --config RelWithDebInfo)
cmake --build . --config %BUILDTYPE%

if exist %BUILD_DIR%\bin\root.exe (
  rem generate binary distribution
  cpack -C %BUILDTYPE%
)

cd %HOME_DIR%


