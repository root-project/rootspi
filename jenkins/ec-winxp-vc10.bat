@echo off 

echo Execution started: %date% %time%

rem ---Compiler------------------------------------------------------
call "%VS100COMNTOOLS%vsvars32.bat"

rem ---GSL-----------------------------------------------------------
set GSL_DIR=D:\external\GSL\1.16

rem ---Options-------------------------------------------------------
set THIS=%~d0%~p0
set ExtraCMakeOptions=";-Droofit=ON"

rem ---Run the CTest script------------------------------------------
ctest -V -S %THIS%root-build.cmake



