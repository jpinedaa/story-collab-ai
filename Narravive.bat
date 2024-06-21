@echo off

REM Start the Flask server in the background
start /B "" "%~dp0narravive_server.exe"

REM Check server status
:CHECKSERVER
timeout /T 1 > NUL
curl http://localhost:5000/health -o NUL
if errorlevel 1 goto CHECKSERVER

REM Start the Flutter app and wait for it to close
start /WAIT "" "%~dp0frontend.exe"

REM Terminate the Flask server
taskkill /IM narravive_server.exe /F

exit
