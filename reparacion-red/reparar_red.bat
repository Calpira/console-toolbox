@echo off
title Reparacion y diagnostico de red
color 0A

echo.
echo  ==========================================
echo    REPARACION Y DIAGNOSTICO DE RED
echo  ==========================================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Pidiendo permisos de administrador
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo Reparando red
echo.

echo [1/11] Estado de red anterior
call :diag "Estado anterior"

echo [2/11] Habilitando adaptadores
powershell -NoProfile -Command "Get-NetAdapter -Physical | Where-Object {$_.Status -eq 'Disabled'} | Enable-NetAdapter -Confirm:$false"

echo [3/11] Reiniciando servicios de red
for %%S in (Dhcp Dnscache NlaSvc netprofm nsi WlanSvc Wcmsvc) do (
    sc query %%S >nul 2>&1
    if not errorlevel 1 (
        sc config %%S start= auto >nul 2>&1
        net start %%S >nul 2>&1
    )
)

echo [4/11] Reset de Winsock
netsh winsock reset

echo [5/11] Reset de la pila IP
powershell -NoProfile -Command "$p = (Get-NetAdapter -Physical).ifIndex; if (Get-NetIPInterface -AddressFamily IPv4 | Where-Object {$p -contains $_.ifIndex -and $_.Dhcp -eq 'Disabled'}) { exit 1 } else { exit 0 }"
if errorlevel 1 (
    echo Se detecto IP fija, se omite el reset de la pila IP
) else (
    netsh int ip reset
)

echo [6/11] Reset de proxy
netsh winhttp reset proxy

echo [7/11] Limpiando cache
ipconfig /flushdns
arp -d *
nbtstat -R
nbtstat -RR

echo [8/11] Liberando IP
ipconfig /release

echo [9/11] Reiniciando adaptador
powershell -NoProfile -Command "Get-NetAdapter -Physical | Where-Object {$_.Status -ne 'Not Present'} | Restart-NetAdapter -Confirm:$false"
timeout /t 5 /nobreak >nul

echo [10/11] Renovando IP
ipconfig /renew

echo [11/11] Registrando DNS
ipconfig /registerdns
timeout /t 3 /nobreak >nul
echo.

echo  ------------------------------------------
echo    Estado final y pruebas
echo  ------------------------------------------
call :diag "Estado final"
call :pruebas

echo.
echo  ==========================================
echo    Proceso terminado
echo  ==========================================
echo.
pause
exit /b

:diag
echo -- %~1 --
powershell -NoProfile -Command "Get-NetAdapter -Physical | Format-Table Name, Status, LinkSpeed -AutoSize; Get-CimInstance Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=true' | Format-List Description, DHCPEnabled, IPAddress, DefaultIPGateway, DHCPServer, DNSServerSearchOrder"
echo.
goto :eof

:pruebas
echo -- Pruebas de conexion --
powershell -NoProfile -Command "$c = Get-CimInstance Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=true'; $ip = @($c.IPAddress | Where-Object {$_ -match '^\d+\.\d+\.\d+\.\d+$'}); $gw = @($c.DefaultIPGateway)[0]; $gwOk = $false; if ($gw) { $gwOk = [bool](Test-Connection $gw -Count 2 -Quiet -ErrorAction SilentlyContinue) }; $net = [bool](Test-Connection 8.8.8.8 -Count 2 -Quiet -ErrorAction SilentlyContinue); $dns = [bool](Resolve-DnsName google.com -ErrorAction SilentlyContinue); Write-Host ('Gateway: ' + $(if (-not $gw) {'sin gateway'} elseif ($gwOk) {'ok'} else {'no responde'})); Write-Host ('Internet: ' + $(if ($net) {'ok'} else {'no responde'})); Write-Host ('DNS: ' + $(if ($dns) {'ok'} else {'falla'})); if (-not $ip) { $res = 'SIN IP' } elseif ($ip | Where-Object {$_ -like '169.254.*'}) { $res = 'IP 169.254' } elseif (-not $gw) { $res = 'Tiene IP pero no tiene gateway' } elseif (-not $gwOk) { $res = 'No responde el gateway' } elseif (-not $net) { $res = 'Llega al gateway pero no sale a internet' } elseif (-not $dns) { $res = 'Hay internet pero falla DNS' } else { $res = 'OK: conexion funcionando' }; Write-Host ''; Write-Host ('RESULTADO: ' + $res); $p = (Get-NetAdapter -Physical).ifIndex; $fija = [bool](Get-NetIPInterface -AddressFamily IPv4 | Where-Object {$p -contains $_.ifIndex -and $_.Dhcp -eq 'Disabled'}); $tipo = $(if ($fija) {'IP fija'} else {'IP dinamica'}); Add-Content -Path '%~dp0log_red.txt' -Value ((Get-Date -Format 'yyyy-MM-dd HH:mm') + ' | ' + $tipo + ' | ' + $res) -ErrorAction SilentlyContinue"
goto :eof
