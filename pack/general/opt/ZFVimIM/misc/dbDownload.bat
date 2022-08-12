@echo off
setlocal
setlocal enabledelayedexpansion

set WORK_DIR=%~dp0
set REPO_PATH=%~1%
set GIT_USER_EMAIL=%~2%
set GIT_USER_NAME=%~3%
set GIT_USER_TOKEN=%~4%
if not defined REPO_PATH goto :usage
goto :run
:usage
exit /b 1
:run

set _OLD_DIR=%cd%
cd /d "%REPO_PATH%"

for /f "delims=" %%a in ('git branch') do @set BRANCH=%%a
set BRANCH=!BRANCH:* =!

if not defined GIT_USER_EMAIL goto :DownloadWithoutAuth
if not defined GIT_USER_NAME goto :DownloadWithoutAuth
if not defined GIT_USER_TOKEN goto :DownloadWithoutAuth


:DownloadWithAuth
for /f "delims=" %%a in ('git remote -v ^| findstr "(push)"') do @set PUSH_URL=%%a
set PUSH_URL=!PUSH_URL:origin	=!
set PUSH_URL=!PUSH_URL: (push)=!
set PUSH_URL=!PUSH_URL:://=://%GIT_USER_NAME%:%GIT_USER_TOKEN%@!

git checkout .
git fetch "%PUSH_URL%" "+refs/heads/*:refs/remotes/origin/*"
git reset --hard origin/%BRANCH%
git clean -xdf
git pull "%PUSH_URL%"
if not "!errorlevel!" == "0" (
    cd /d "%_OLD_DIR%"
    exit /b 1
)
git gc --prune=now

cd /d "%_OLD_DIR%"

exit /b 0


:DownloadWithoutAuth
git checkout .
git fetch --all
git reset --hard origin/%BRANCH%
git clean -xdf
git pull
if not "!errorlevel!" == "0" (
    cd /d "%_OLD_DIR%"
    exit /b 1
)
git gc --prune=now

cd /d "%_OLD_DIR%"

exit /b 0

