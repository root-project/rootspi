@echo off

echo Execution started: %date% %time%

rem ---Compiler------------------------------------------------------
if %COMPILER% == vc9   call "%VS90COMNTOOLS%vsvars32.bat"
if %COMPILER% == vc10  call "%VS100COMNTOOLS%vsvars32.bat"
if %COMPILER% == vc11  call "%VS110COMNTOOLS%vsvars32.bat"
if %COMPILER% == vc12  call "%VS120COMNTOOLS%vsvars32.bat"
if %COMPILER% == vc13  call "%VS130COMNTOOLS%vsvars32.bat"
if %COMPILER% == vc15  call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat"
if %COMPILER% == native call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars32.bat" x86

rem ---External libraries--------------------------------------------
rem set GSL_DIR=C:\libs\gsl-1.14

if %VERSION% == master (
  set Version.Major=6
  set Version.Minor=99
  set Version.Build=99
) else (
  for /f "delims=. tokens=1-3" %%a in ("%VERSION%") do (
    set Version.Major=%%a
    set Version.Minor=%%b
    set Version.Build=%%c
  )
)

rem ---Options-------------------------------------------------------
set THIS=%~d0%~p0
if %Version.Major% == 6 (
  if %Version.Minor% geq 16 (
    set "ExtraCMakeOptions=-DCMAKE_VERBOSE_MAKEFILE=ON -Wno-dev=ON -Dall=OFF -Dbuiltin_tbb=ON -Dbuiltin_unuran=ON -Dimt=ON -Dmathmore=ON -DGSL_CBLAS_LIBRARY=C:/libs/vs2017/GSL/2.5/lib/gslcblas.lib -DGSL_INCLUDE_DIR=C:/libs/vs2017/GSL/2.5/include -DGSL_LIBRARY=C:/libs/vs2017/GSL/2.5/lib/gsl.lib -Dminuit2=ON -Droofit=ON -Droot7=OFF -Dtmva=OFF -Dunuran=ON -Dvc=OFF -Dtesting=ON -Droottest=OFF"
  ) else (
    set "ExtraCMakeOptions=-DCMAKE_VERBOSE_MAKEFILE=ON -Wno-dev=ON -Dall=OFF -Dbuiltin_tbb=OFF -Dbuiltin_unuran=OFF -Dimt=OFF -Dminuit2=ON -Droofit=ON -Droot7=OFF -Dtmva=OFF -Dunuran=OFF -Dvc=OFF -Dtesting=ON -Droottest=OFF"
  )
) else (
  set ExtraCMakeOptions=";-Droofit=ON"
)

echo Dumping the full environment ---------------------------------------------------------
set
echo --------------------------------------------------------------------------------------

rem ---Run the CTest script depending on the compiler------------------------------------------
ctest -VV -S %THIS%/root-build.cmake
if %ERRORLEVEL% neq 0 (
  exit /B %ERRORLEVEL%
)
if not %COMPILER% == vc15 (
  if not %COMPILER% == native (
    ctest -V -S %THIS%/root-test.cmake
  )
)

exit /B %ERRORLEVEL%

