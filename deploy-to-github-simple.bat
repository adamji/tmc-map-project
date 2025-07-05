@echo off
REM TMC Map GitHub Deploy Script (Simplified - No Docker Required)
REM Usage: deploy-to-github-simple.bat [github-username] [repo-name]

chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

if "%~2"=="" (
    echo [ERROR] Usage: %0 [github-username] [repo-name]
    echo [INFO] Example: %0 myusername tmc-map-project
    exit /b 1
)

set GITHUB_USERNAME=%1
set REPO_NAME=%2
set GITHUB_REPO=https://github.com/%GITHUB_USERNAME%/%REPO_NAME%.git

echo [INFO] === TMC Map GitHub Deploy Script (Simplified) ===
echo [INFO] GitHub Username: %GITHUB_USERNAME%
echo [INFO] Repository Name: %REPO_NAME%
echo [INFO] Repository URL: %GITHUB_REPO%

REM Check Git only
echo [INFO] Checking Git installation...
where git >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERROR] Git is not installed. Please install Git first.
    echo [INFO] Download: https://git-scm.com/download/win
    exit /b 1
)

REM Initialize Git repository
echo [INFO] Initializing Git repository...
if not exist ".git" (
    git init
    echo [INFO] Git repository initialized
) else (
    echo [WARN] Git repository already exists
)

REM Add remote repository
echo [INFO] Configuring remote repository...
git remote get-url origin >nul 2>&1
if %errorlevel% equ 0 (
    echo [WARN] Remote repository exists, updating URL...
    git remote set-url origin %GITHUB_REPO%
) else (
    git remote add origin %GITHUB_REPO%
    echo [INFO] Remote repository added
)

REM Add all files to Git
echo [INFO] Adding files to Git...
git add .

REM Commit code
echo [INFO] Committing code...
for /f "tokens=2 delims==" %%a in ('wmic OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "timestamp=%YYYY%-%MM%-%DD% %HH%:%Min%:%Sec%"

git commit -m "Deploy TMC Map project - %timestamp%"
if %errorlevel% neq 0 (
    echo [WARN] No new commits
)

REM Push to GitHub
echo [INFO] Pushing code to GitHub...
git push -u origin main
if %errorlevel% neq 0 (
    git push -u origin master
)

echo [INFO] Code successfully pushed to GitHub!

REM Generate configuration guide
echo [INFO] === GitHub Actions will handle the following steps automatically ===
echo [INFO] ✅ Build Docker images
echo [INFO] ✅ Push to Docker Hub
echo [INFO] ✅ Deploy to server
echo [INFO] ✅ Deploy to WeChat Cloud Hosting
echo [INFO]
echo [INFO] === Next Steps Guide ===
echo [INFO] 1. Configure the following Secrets in your GitHub repository:
echo [INFO]    Settings → Secrets and variables → Actions → New repository secret
echo [INFO]
echo [INFO] Required Secrets:
echo [INFO]    - DOCKER_USERNAME: Docker Hub username
echo [INFO]    - DOCKER_PASSWORD: Docker Hub password
echo [INFO]
echo [INFO] Optional Secrets (if deploying to server):
echo [INFO]    - HOST: Server IP address
echo [INFO]    - USERNAME: Server username
echo [INFO]    - KEY: Server SSH private key
echo [INFO]
echo [INFO] Optional Secrets (if deploying to WeChat Cloud Hosting):
echo [INFO]    - CLOUDBASE_SECRET_KEY: Cloud development secret key
echo [INFO]    - CLOUDBASE_ENV_ID: Cloud development environment ID
echo [INFO]
echo [INFO] 2. Push code to main branch will automatically trigger deployment
echo [INFO]
echo [INFO] 3. Check deployment status:
echo [INFO]    Visit: %GITHUB_REPO%/actions
echo [INFO]
echo [INFO] GitHub repository URL: %GITHUB_REPO%
echo [INFO] Deployment complete! 🎉 All Docker operations are done in the cloud!

pause 