@echo off
REM Simple GitHub Upload Script - Only Git Required
REM Usage: upload-to-github.bat [github-username] [repo-name]

chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

if "%~2"=="" (
    echo ERROR: Usage: %0 [github-username] [repo-name]
    echo Example: %0 myusername tmc-map-project
    pause
    exit /b 1
)

set GITHUB_USERNAME=%1
set REPO_NAME=%2
set GITHUB_REPO=https://github.com/%GITHUB_USERNAME%/%REPO_NAME%.git

echo.
echo ========================================
echo   TMC Map GitHub Upload Script
echo ========================================
echo GitHub Username: %GITHUB_USERNAME%
echo Repository Name: %REPO_NAME%
echo Repository URL: %GITHUB_REPO%
echo.

REM Check Git only
echo Checking Git installation...
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo ERROR: Git is not installed!
    echo Please download and install Git from: https://git-scm.com/download/win
    pause
    exit /b 1
)
echo ✅ Git is installed

REM Initialize Git repository
echo.
echo Initializing Git repository...
if not exist ".git" (
    git init
    echo ✅ Git repository initialized
) else (
    echo ⚠️  Git repository already exists
)

REM Add remote repository
echo.
echo Configuring remote repository...
git remote get-url origin >nul 2>&1
if %errorlevel% equ 0 (
    echo ⚠️  Remote repository exists, updating URL...
    git remote set-url origin %GITHUB_REPO%
) else (
    git remote add origin %GITHUB_REPO%
    echo ✅ Remote repository added
)

REM Add all files to Git
echo.
echo Adding files to Git...
git add .
echo ✅ Files added to Git

REM Commit code
echo.
echo Committing code...
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "timestamp=%YYYY%-%MM%-%DD% %HH%:%Min%:%Sec%"

git commit -m "Upload TMC Map project - %timestamp%"
if %errorlevel% neq 0 (
    echo ⚠️  No new commits to push
    goto :push
)
echo ✅ Code committed

:push
REM Push to GitHub
echo.
echo Pushing code to GitHub...
git push -u origin main
if %errorlevel% neq 0 (
    echo Trying master branch...
    git push -u origin master
    if %errorlevel% neq 0 (
        echo ERROR: Failed to push to GitHub
        echo Make sure you have created the repository on GitHub first
        pause
        exit /b 1
    )
)

echo.
echo ========================================
echo   SUCCESS! Code uploaded to GitHub
echo ========================================
echo.
echo Repository URL: %GITHUB_REPO%
echo.
echo Next Steps:
echo 1. Go to your GitHub repository
echo 2. Check if all files are uploaded correctly
echo 3. You can now deploy using GitHub Actions or WeChat Cloud Hosting
echo.

pause 