@echo off
echo ========================================
echo Quick Docker Test for TMC Map Backend
echo ========================================

echo.
echo Building Docker image with China mirrors...
docker build -f ./tmc-map-backend/Dockerfile.china -t tmc-map-backend:test ./tmc-map-backend

if %ERRORLEVEL% NEQ 0 (
    echo Build failed!
    pause
    exit /b 1
)

echo.
echo Starting container...
docker stop tmc-map-test 2>nul
docker rm tmc-map-test 2>nul
docker run -d --name tmc-map-test -p 8080:8080 tmc-map-backend:test

echo.
echo Waiting for startup...
timeout /t 15 /nobreak >nul

echo.
echo Testing endpoints...
echo Health check:
curl -s http://localhost:8080/api/actuator/health
echo.
echo API test:
curl -s http://localhost:8080/api/clubs

echo.
echo Container logs:
docker logs tmc-map-test --tail 10

echo.
echo ========================================
echo Test completed!
echo ========================================
echo Container running on http://localhost:8080
echo To stop: docker stop tmc-map-test
echo.

pause 