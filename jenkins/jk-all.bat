@echo off

echo Execution started: %date% %time%

rem ---Compiler------------------------------------------------------
if %COMPILER% == vc9   call "%VS90COMNTOOLS%vsvars32.bat"
if %COMPILER% == vc10  call "%VS100COMNTOOLS%vsvars32.bat"
if %COMPILER% == vc11  call "%VS110COMNTOOLS%vsvars32.bat"
if %COMPILER% == vc12  call "%VS120COMNTOOLS%vsvars32.bat"
if %COMPILER% == vc13  call "%VS130COMNTOOLS%vsvars32.bat"
if %COMPILER% == vc15  call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat"

rem ---External libraries--------------------------------------------
rem set GSL_DIR=C:\libs\gsl-1.14

rem ---Options-------------------------------------------------------
set THIS=%~d0%~p0
if %COMPILER% == vc15 (
  set ExtraCMakeOptions=";-Dall=OFF; -Dcxx11=OFF; -Dcxx14=ON; -Dtmva=OFF; -Dimt=OFF; -Dbuiltin_tbb=OFF; -Dtesting=OFF; -Droottest=OFF"
) else (
  set ExtraCMakeOptions=";-Droofit=ON"
)

echo Dumping the full environment ---------------------------------------------------------
set
echo --------------------------------------------------------------------------------------

rem ---Run the CTest script depending on the compiler------------------------------------------
ctest -VV -S %THIS%/root-build.cmake
if not %COMPILER% == vc15 (
  ctest -V  -S %THIS%/root-test.cmake
)


