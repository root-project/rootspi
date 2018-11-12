@echo off

echo Execution started: %date% %time%

rem ---Compiler------------------------------------------------------
if "%COMPILER%" == "" (
  call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars32.bat" x86
) else (
  if %COMPILER% == vc9   call "%VS90COMNTOOLS%vsvars32.bat"
  if %COMPILER% == vc10  call "%VS100COMNTOOLS%vsvars32.bat"
  if %COMPILER% == vc11  call "%VS110COMNTOOLS%vsvars32.bat"
  if %COMPILER% == vc12  call "%VS120COMNTOOLS%vsvars32.bat"
  if %COMPILER% == vc13  call "%VS130COMNTOOLS%vsvars32.bat"
  if %COMPILER% == vc15  call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat"
  if %COMPILER% == native call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars32.bat" x86
)

echo Dumping the full environment ---------------------------------------------------------
set
echo --------------------------------------------------------------------------------------

rem ---Run the CTest script depending on the compiler------------------------------------------
set THIS=%~d0%~p0
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

