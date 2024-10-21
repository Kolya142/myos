@echo off
setlocal

set "URL=https://qemu.weilnetz.de/w64/2024/qemu-w64-setup-20240903.exe"
set "OUTPUT=qemu-w64-setup-20240903.exe"

echo Downloading %URL%...
powershell -Command "Invoke-WebRequest -Uri %URL% -OutFile %OUTPUT%"

if exist %OUTPUT% (
    echo Download successful.
    echo Running the installer...
    start "" "%OUTPUT%"
) else (
    echo Download failed.
)

endlocal