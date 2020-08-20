@echo off

setlocal enabledelayedexpansion

echo Execution started: %date% %time%

rem ---Compiler------------------------------------------------------
rem if "%COMPILER%" == "" (
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars32.bat" (
  call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvars32.bat" x86
) else if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars32.bat" (
  call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars32.bat" x86
)
rem ) else (
rem   if %COMPILER% == vc9   call "%VS90COMNTOOLS%vsvars32.bat"
rem   if %COMPILER% == vc10  call "%VS100COMNTOOLS%vsvars32.bat"
rem   if %COMPILER% == vc11  call "%VS110COMNTOOLS%vsvars32.bat"
rem   if %COMPILER% == vc12  call "%VS120COMNTOOLS%vsvars32.bat"
rem   if %COMPILER% == vc13  call "%VS130COMNTOOLS%vsvars32.bat"
rem   if %COMPILER% == vc15  call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat"
rem   if %COMPILER% == native call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvars32.bat" x86
rem )

echo Dumping the full environment ---------------------------------------------------------
set
echo --------------------------------------------------------------------------------------

rem ---Run the CTest script depending on the compiler------------------------------------------

set THIS=%~d0%~p0
set NCORES=%NUMBER_OF_PROCESSORS%
if "!NCORES!" == "" set NCORES=4
if "!NCORES!" == "32" set NCORES=16
set ACTION=%1
set RUN_TESTS=no

if "%VERSION%" neq "" (
    if "%VERSION%" == "master" (
        set RUN_TESTS=yes
    ) else (
        if "%VERSION:~0,1%" == "v" set VERSION=%VERSION:~1%
        for /F "tokens=1,2,3 delims=.-" %%a in ("!VERSION!") do (
            set Major=%%a
            set Minor=%%b
            set Revision=%%c
        )
        if !Major! == 6 (
            if !Minor! geq 23 (
                set RUN_TESTS=yes
            )
        )
        if !Major! geq 7 set RUN_TESTS=yes
    )
)

if "!ACTION!" neq "test" (

    ctest -j!NCORES! -VV -S !THIS!/root-build.cmake
    set status=%errorlevel%

    rem do not run the tests if continuous build fails
    if !status! neq 0 (
        if "%MODE%" == "continuous" (
            exit /b !status!
        )
    )

    rem do not run tests if coverity run or package build.
    if "%BUILDOPTS%" == "coverity" (
        exit /b !status!
    )
    if "%MODE%" == "package" (
        exit /b !status!
    )
)

if "!ACTION!" neq "build" (
    if "!RUN_TESTS!" == "yes" (
        ctest -j!NCORES! --no-compress-output -V -S !THIS!/root-test.cmake
    )
)

exit /b %errorlevel%

