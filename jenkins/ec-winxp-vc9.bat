@echo off  
echo Execution started: %date% %time%

rem ---Set Visual Studio environment---------------------------------
call "%VS90COMNTOOLS%vsvars32.bat"

rem ---GSL-----------------------------------------------------------
set GSL_DIR=D:\external\GSL\1.16

set THIS=%~d0%~p0

rem ---Run the CTest script-------------------------------------------
ctest -V -S %THIS%root-build.cmake


