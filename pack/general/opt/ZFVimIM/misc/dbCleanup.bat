@echo off
setlocal
setlocal enabledelayedexpansion

set WORK_DIR=%~dp0
set REPO_PATH=%~1%
set GIT_USER_EMAIL=%~2%
set GIT_USER_NAME=%~3%
set GIT_USER_TOKEN=%~4%
set CLEANUP_SCRIPT=%~5%
set DB_CLEANUP_CACHE_PATH=%~6%
if not defined REPO_PATH goto :usage
if not defined GIT_USER_EMAIL goto :usage
if not defined GIT_USER_NAME goto :usage
if not defined GIT_USER_TOKEN goto :usage
if not defined CLEANUP_SCRIPT goto :usage
if not defined DB_CLEANUP_CACHE_PATH goto :usage
goto :run
:usage
exit /b 1
:run

del /f/s/q "%DB_CLEANUP_CACHE_PATH%" >nul 2>&1
rmdir /s/q "%DB_CLEANUP_CACHE_PATH%" >nul 2>&1
mkdir "%DB_CLEANUP_CACHE_PATH%"
xcopy /s/e/y/r/h "%REPO_PATH%\.git" "%DB_CLEANUP_CACHE_PATH%\.git\" >nul 2>&1
call "%CLEANUP_SCRIPT%" "%DB_CLEANUP_CACHE_PATH%" "%GIT_USER_EMAIL%" "%GIT_USER_NAME%" "%GIT_USER_TOKEN%"
set result=%errorlevel%
del /f/s/q "%DB_CLEANUP_CACHE_PATH%" >nul 2>&1
rmdir /s/q "%DB_CLEANUP_CACHE_PATH%" >nul 2>&1
exit /b %result%

