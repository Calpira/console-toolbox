@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
title Limpieza del sistema

:: ============================================================
:: Pedir permisos de administrador (auto-elevación)
:: ============================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Pidiendo permisos de administrador...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo.
echo -------------------------------
echo Ejecutando limpieza del sistema
echo -------------------------------
echo.

:: ============================================================
:: Espacio libre antes (en MB)
:: ============================================================
for /f %%a in ('powershell -NoProfile -Command "[math]::Round((Get-PSDrive C).Free/1MB)"') do set LIBRE_ANTES=%%a

echo Espacio libre antes: %LIBRE_ANTES% MB
echo.

:: ============================================================
:: Limpiar caché de paquetes (Windows Update)
:: ============================================================
echo Limpiando cache de Windows Update...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
if exist "%windir%\SoftwareDistribution\Download" (
    del /f /s /q "%windir%\SoftwareDistribution\Download\*.*" >nul 2>&1
    for /d %%d in ("%windir%\SoftwareDistribution\Download\*") do rd /s /q "%%d" >nul 2>&1
)
net start wuauserv >nul 2>&1
net start bits >nul 2>&1

:: ============================================================
:: Eliminar paquetes huerfanos (componentes antiguos de WinSxS)
:: ============================================================
echo.
echo Eliminando componentes antiguos del sistema...
dism /online /cleanup-image /startcomponentcleanup /resetbase

:: ============================================================
:: Reparar paquetes pendientes
:: ============================================================
echo.
echo Reparando imagen del sistema...
dism /online /cleanup-image /restorehealth

echo.
echo Verificando archivos de sistema...
sfc /scannow

:: ============================================================
:: Limpiar logs antiguos
:: ============================================================
echo.
echo Limpiando registros de eventos antiguos...
for /f "tokens=*" %%L in ('wevtutil el') do (
    wevtutil cl "%%L" >nul 2>&1
)

:: ============================================================
:: Limpiar temporales del sistema
:: ============================================================
echo.
echo Limpiando archivos temporales del sistema...
del /f /s /q "%TEMP%\*.*" >nul 2>&1
for /d %%d in ("%TEMP%\*") do rd /s /q "%%d" >nul 2>&1

del /f /s /q "%windir%\Temp\*.*" >nul 2>&1
for /d %%d in ("%windir%\Temp\*") do rd /s /q "%%d" >nul 2>&1

del /f /s /q "%windir%\Prefetch\*.*" >nul 2>&1

:: ============================================================
:: Limpiar cache de cada usuario
:: ============================================================
echo.
echo Examinando cache de usuarios...
for /d %%U in ("C:\Users\*") do (
    if exist "%%U\AppData\Local\Temp" (
        echo   -^> Limpiando cache de %%~nxU
        del /f /s /q "%%U\AppData\Local\Temp\*.*" >nul 2>&1
        for /d %%d in ("%%U\AppData\Local\Temp\*") do rd /s /q "%%d" >nul 2>&1
    )

    :: Cache de miniaturas e iconos
    if exist "%%U\AppData\Local\Microsoft\Windows\Explorer" (
        del /f /s /q "%%U\AppData\Local\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
        del /f /s /q "%%U\AppData\Local\Microsoft\Windows\Explorer\iconcache_*.db" >nul 2>&1
    )

    :: Cache de navegadores
    if exist "%%U\AppData\Local\Google\Chrome\User Data\Default\Cache" (
        del /f /s /q "%%U\AppData\Local\Google\Chrome\User Data\Default\Cache\*.*" >nul 2>&1
    )
    if exist "%%U\AppData\Local\Microsoft\Edge\User Data\Default\Cache" (
        del /f /s /q "%%U\AppData\Local\Microsoft\Edge\User Data\Default\Cache\*.*" >nul 2>&1
    )
)

:: ============================================================
:: Vaciar papelera de reciclaje
:: ============================================================
echo.
echo Vaciando papelera de reciclaje...
powershell -NoProfile -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"

:: ============================================================
:: Liberador de espacio en disco (silencioso)
:: ============================================================
echo.
echo Ejecutando liberador de espacio en disco...
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Temporary Files" /v StateFlags0001 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Recycle Bin" /v StateFlags0001 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Thumbnail Cache" /v StateFlags0001 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Downloaded Program Files" /v StateFlags0001 /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches\Old ChkDsk Files" /v StateFlags0001 /t REG_DWORD /d 2 /f >nul 2>&1
cleanmgr /sagerun:1

:: ============================================================
:: Espacio libre despues
:: ============================================================
echo.
echo -------------------------------
echo Limpieza terminada
echo -------------------------------
echo.

for /f %%a in ('powershell -NoProfile -Command "[math]::Round((Get-PSDrive C).Free/1MB)"') do set LIBRE_DESPUES=%%a
set /a LIBERADO=%LIBRE_DESPUES% - %LIBRE_ANTES%

echo Estado final del disco:
echo.
powershell -NoProfile -Command "Get-PSDrive -PSProvider FileSystem | Format-Table Name,Used,Free -AutoSize"

echo.
echo Espacio liberado: %LIBERADO% MB
echo -------------------------------
echo.

pause
endlocal