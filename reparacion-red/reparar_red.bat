
@echo off
title Reparacion de red
color 0A

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Pidiendo permisos de administrador
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

echo Reparando red
echo.

call :diag "Inicio"

echo Habilitando adaptadores
powershell -NoProfile -Command "Get-NetAdapter -Physical | Where-Object {$_.Status -eq 'Disabled'} | Enable-NetAdapter -Confirm:$false"

echo Reiniciando servicios de red
for %%S in (Dhcp Dnscache NlaSvc netprofm nsi WlanSvc Wcmsvc) do (
    sc query %%S >nul 2>&1
    if not errorlevel 1 (
        sc config %%S start= auto >nul 2>&1
        net start %%S >nul 2>&1
    )
)

echo Reset de Winsock
netsh winsock reset

echo Reset de la pila IP
netsh int ip reset

echo Reset de proxy
netsh winhttp reset proxy

echo Limpiando cache
ipconfig /flushdns
arp -d *
nbtstat -R
nbtstat -RR

echo Liberando IP
ipconfig /release

echo Reiniciando adaptador
powershell -NoProfile -Command "Get-NetAdapter -Physical | Where-Object {$_.Status -ne 'Not Present'} | Restart-NetAdapter -Confirm:$false"
timeout /t 5 /nobreak >nul

echo Renovando IP
ipconfig /renew

echo Registrando DNS
ipconfig /registerdns
timeout /t 3 /nobreak >nul
echo.

call :diag "Fin"
call :pruebas

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
powershell -NoProfile -Command "$c = Get-CimInstance Win32_NetworkAdapterConfiguration -Filter 'IPEnabled=true'; $ip = @($c.IPAddress | Where-Object {$_ -match '^\d+\.\d+\.\d+\.\d+$'}); $gw = @($c.DefaultIPGateway)[0]; $gwOk = $false; if ($gw) { $gwOk = [bool](Test-Connection $gw -Count 2 -Quiet -ErrorAction SilentlyContinue) }; $net = [bool](Test-Connection 8.8.8.8 -Count 2 -Quiet -ErrorAction SilentlyContinue); $dns = [bool](Resolve-DnsName google.com -ErrorAction SilentlyContinue); Write-Host ('Gateway: ' + $(if (-not $gw) {'sin gateway'} elseif ($gwOk) {'ok'} else {'no responde'})); Write-Host ('Internet: ' + $(if ($net) {'ok'} else {'no responde'})); Write-Host ('DNS: ' + $(if ($dns) {'ok'} else {'falla'})); if (-not $ip) { $res = 'sin IP' } elseif ($ip | Where-Object {$_ -like '169.254.*'}) { $res = 'IP 169.254, sin respuesta de DHCP' } elseif (-not $gw) { $res = 'sin gateway' } elseif (-not $gwOk) { $res = 'gateway no responde' } elseif (-not $net) { $res = 'sin salida a internet' } elseif (-not $dns) { $res = 'falla DNS' } else { $res = 'ok' }; Write-Host ''; Write-Host ('Resultado: ' + $res); Add-Content -Path '%~dp0log_red.txt' -Value (Get-Date -Format 'yyyy-MM-dd HH:mm') -ErrorAction SilentlyContinue"
goto :eof
