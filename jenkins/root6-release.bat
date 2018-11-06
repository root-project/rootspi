rem @echo off

echo Execution started: %date% %time%

rem ---Compiler------------------------------------------------------
rem call "%vsappiddir%..\..\VC\Auxiliary\Build\vcvars32.bat" x86
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars32.bat" x86
set VC_DIR=vc15

rem ---Options-------------------------------------------------------
set THIS=%~d0%~p0

set DEST=root_v%VERSION%

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

set SOURCE_DIR=%ROOT_SOURCE_PREFIX%
set BUILD_DIR=%ROOT_BUILD_PREFIX%\build\root-%VERSION%
set INSTALL_DIR=%ROOT_BUILD_PREFIX%\install\ROOT\%VERSION%

set DRIVE=%~d0
set HOME_DIR=%CD%

if not exist %SOURCE_DIR% mkdir %SOURCE_DIR%
cd %SOURCE_DIR%
set TAR_CMD="%ProgramFiles%\7-Zip\7z.exe"
set SRC_TAR_FILE="root_v%VERSION%.source.tar.gz"
if not exist %SRC_TAR_FILE% (
   powershell -NoProfile -Command "(new-object System.Net.WebClient).DownloadFile('http://root.cern.ch/download/%SRC_TAR_FILE%', '%SRC_TAR_FILE%')"
)
if not exist %SOURCE_DIR%\root-%VERSION% %TAR_CMD% x %SRC_TAR_FILE% -so | %TAR_CMD% x -aoa -si -ttar

echo Dumping the full environment ---------------------------------------------------------
set
echo --------------------------------------------------------------------------------------

if not exist %BUILD_DIR% mkdir %BUILD_DIR%
cd %BUILD_DIR%

cmake -DCMAKE_BUILD_TYPE=%BUILDTYPE% ^
      -DCMAKE_INSTALL_PREFIX=%INSTALL_DIR%\root ^
      -DCMAKE_VERBOSE_MAKEFILE=ON ^
      -Wno-dev=ON ^
      -Dall=OFF ^
      -Dbuiltin_tbb=OFF ^
      -Dbuiltin_unuran=OFF ^
      -Dimt=OFF ^
      -Dminuit2=ON ^
      -Droofit=ON ^
      -Droot7=OFF ^
      -Dtmva=OFF ^
      -Dunuran=OFF ^
      -Dvc=OFF ^
      -G"Visual Studio 15 2017" ^
      %SOURCE_DIR%\root-%VERSION%

rem now lets start the build (e.g. cmake --build . --config Debug)
cmake --build . --config %BUILDTYPE%

if exist %BUILD_DIR%\bin\root.exe (
  rem generate binary distribution
  cpack -C %BUILDTYPE%
)
rem rename files to have the "debug" part in lowercase
if exist root_v?.??.??.?????.????.Debug.??? (
   ren root_v?.??.??.?????.????.Debug.??? root_v?.??.??.?????.????.debug.???
)
if exist root_v?.??.??.?????.????.Debug.???.?? (
   ren root_v?.??.??.?????.????.Debug.???.?? root_v?.??.??.?????.????.debug.???.??
)

cd %HOME_DIR%


