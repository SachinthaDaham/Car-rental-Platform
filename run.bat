@echo off
echo ================================
echo  VehicleRentalPlatform - Run
echo ================================

echo [1/4] Building project...
call mvn clean package -DskipTests -q
if %ERRORLEVEL% neq 0 (
    echo BUILD FAILED. Fix errors and try again.
    pause
    exit /b 1
)
echo Build successful!

echo [2/4] Stopping Tomcat...
call "C:\Users\LENOVO\Downloads\apache-tomcat-10.1.24\bin\shutdown.bat" 2>nul
timeout /t 3 /nobreak >nul

echo [3/4] Deploying WAR...
if exist "C:\Users\LENOVO\Downloads\apache-tomcat-10.1.24\webapps\VehicleRentalPlatform.war" (
    del /F /Q "C:\Users\LENOVO\Downloads\apache-tomcat-10.1.24\webapps\VehicleRentalPlatform.war"
)
if exist "C:\Users\LENOVO\Downloads\apache-tomcat-10.1.24\webapps\VehicleRentalPlatform" (
    rmdir /S /Q "C:\Users\LENOVO\Downloads\apache-tomcat-10.1.24\webapps\VehicleRentalPlatform"
)
copy /Y "target\VehicleRentalPlatform.war" "C:\Users\LENOVO\Downloads\apache-tomcat-10.1.24\webapps\VehicleRentalPlatform.war"

echo [4/4] Starting Tomcat...
start "" "C:\Users\LENOVO\Downloads\apache-tomcat-10.1.24\bin\startup.bat"
timeout /t 5 /nobreak >nul

echo ================================
echo  App running at:
echo  http://localhost:8081/VehicleRentalPlatform/
echo ================================
echo Press any key to open in browser...
pause >nul
start http://localhost:8081/VehicleRentalPlatform/
