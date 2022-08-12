@echo off
setlocal
setlocal enabledelayedexpansion

set WORK_DIR=%~dp0
set REPO_PATH=%~1%
set GIT_USER_EMAIL=%~2%
set GIT_USER_NAME=%~3%
set GIT_USER_TOKEN=%~4%
if not defined REPO_PATH goto :usage
if not defined GIT_USER_EMAIL goto :usage
if not defined GIT_USER_NAME goto :usage
if not defined GIT_USER_TOKEN goto :usage
goto :run
:usage
exit /b 1
:run

set _OLD_DIR=%cd%
cd /d "%REPO_PATH%"

for /f "delims=" %%a in ('git remote -v ^| findstr "(push)"') do @set PUSH_URL=%%a
set PUSH_URL=!PUSH_URL:origin	=!
set PUSH_URL=!PUSH_URL: (push)=!
set PUSH_URL=!PUSH_URL:://=://%GIT_USER_NAME%:%GIT_USER_TOKEN%@!

git config user.email "%GIT_USER_EMAIL%"
git config user.name "%GIT_USER_NAME%"
git add -A
git commit -m "update"
git push "%PUSH_URL%" HEAD
if not "!errorlevel!" == "0" (
    cd /d "%_OLD_DIR%"
    exit /b 1
)
git fetch "%PUSH_URL%" "+refs/heads/*:refs/remotes/origin/*"

cd /d "%_OLD_DIR%"

exit /b 0

