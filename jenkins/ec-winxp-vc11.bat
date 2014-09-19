@echo off 

echo Execution started: %date% %time%

rem ---Compiler------------------------------------------------------
call "%VS110COMNTOOLS%vsvars32.bat"

rem ---GSL-----------------------------------------------------------
set GSL_DIR=C:\libs\gsl-1.14

rem ---Options-------------------------------------------------------
set THIS=%~d0%~p0
set ExtraCMakeOptions=";-Droofit=ON"

rem ---Run the CTest script------------------------------------------
ctest -V -S %THIS%root-build.cmake



