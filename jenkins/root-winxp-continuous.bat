@echo off  
echo Execution started: %date% %time%

svn update D:/ROOT-scripts

set SOURCE_PREFIX=D:/ROOT-sources
set BUILD_PREFIX=D:/ROOT-builds

set BUILDTYPE=RelWithDebInfo
set MODE=continuous
set VERSION=v5-34-00-patches

if "%1" EQU "" (
  set platform=winxp-vc10
) else (
  set platform=%1
)

set THIS=%~d0%~p0
cmd /C "%THIS%ec-%platform%.bat"


