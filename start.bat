@echo off
title SpringBoot Demo 916 - Auto Deploy Script
color 0A

echo.
echo ========================================
echo   SpringBoot Demo 916 Auto Deploy
echo ========================================
echo.

set APP_NAME=springboot-demo-916
set JAR_FILE=target\%APP_NAME%.jar
set DEPLOY_DIR=C:\apps\%APP_NAME%
set LOG_FILE=%DEPLOY_DIR%\app.log

echo [INFO] Checking if JAR file exists...
if not exist "%JAR_FILE%" (
    echo [ERROR] JAR file not found: %JAR_FILE%
    echo [INFO] Please run 'mvn clean package' first
    pause
    exit /b 1
)

echo [INFO] Stopping existing application...
taskkill /F /FI "WINDOWTITLE eq %APP_NAME%*" 2>nul
if errorlevel 1 (
    echo [INFO] No existing application found
) else (
    echo [INFO] Existing application stopped
)

echo [INFO] Creating deployment directory...
if not exist "%DEPLOY_DIR%" (
    mkdir "%DEPLOY_DIR%"
    echo [INFO] Created directory: %DEPLOY_DIR%
) else (
    echo [INFO] Directory already exists: %DEPLOY_DIR%
)

echo [INFO] Copying JAR file to deployment directory...
copy "%JAR_FILE%" "%DEPLOY_DIR%\" >nul
if errorlevel 1 (
    echo [ERROR] Failed to copy JAR file
    pause
    exit /b 1
)
echo [INFO] JAR file copied successfully

echo [INFO] Starting SpringBoot application...
cd /d "%DEPLOY_DIR%"
start "%APP_NAME%" java -jar %APP_NAME%.jar

echo [INFO] Waiting for application to start...
timeout /t 3 /nobreak >nul

echo [INFO] Checking application status...
for /L %%i in (1,1,10) do (
    curl -s http://localhost:8080 >nul 2>&1
    if not errorlevel 1 (
        echo.
        echo ========================================
        echo   APPLICATION STARTED SUCCESSFULLY!
        echo ========================================
        echo   URL: http://localhost:8080
        echo   Log: %LOG_FILE%
        echo   Deploy Dir: %DEPLOY_DIR%
        echo ========================================
        goto :end
    )
    echo [INFO] Waiting... (%%i/10)
    timeout /t 2 /nobreak >nul
)

echo [WARNING] Application may still be starting...
echo [INFO] Check the application window or log file: %LOG_FILE%

:end
echo.
pause