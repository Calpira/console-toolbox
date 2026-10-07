# Reparar red 

Script `.bat` para Windows 10 que repara problemas comunes de conexión **sin necesidad de reiniciar la PC**.

## Qué hace

1. **Pide permisos de administrador** automáticamente (se relanza elevado).
2. **Muestra el estado de red anterior** a la reparación (adaptadores, IP, gateway, servidor DHCP, DNS).
3. **Habilita adaptadores de red deshabilitados.**
4. **Asegura que estén corriendo los servicios de red** (DHCP Client, DNS Client, NLA, WLAN AutoConfig, etc.).
5. **Activa DHCP** en los adaptadores que lo tengan deshabilitado (opcional, ver [Configuración](#configuración)).
6. **Reset de Winsock y de la pila IP** (`netsh winsock reset`, `netsh int ip reset`).
7. **Limpia el proxy WinHTTP.**
8. **Limpia cachés** DNS, ARP y NetBIOS.
9. **Libera la IP**, **reinicia los adaptadores** físicos y **renueva la IP**.
10. **Re-registra el DNS.**
11. **Muestra el estado final**, hace pruebas de conectividad y da un **diagnóstico en una línea**.
12. **Guarda un log** (`log_red.txt`) junto al script, con nombre y número de serie de la PC.


## Uso

1. Descargar `reparar_red.bat` y ejecutar.
3. Aceptá el aviso.
4. Esperá a que termine y leé el `RESULTADO` final. 


## Configuración

Al inicio del script hay una variable:

```bat
set FORZAR_DHCP=1
```

- `1` (por defecto): pasa a DHCP automático los adaptadores que lo tengan deshabilitado y **borra los DNS manuales** de esos adaptadores.
- `0`: no toca la configuración IP. Usalo si hay equipos con **IP fija a propósito**.

## Diagnóstico

Al final el script indica dónde está el problema:

| Resultado | Qué significa |
|---|---|
| `OK: conexion funcionando` | Todo en orden. |
| `SIN IP` | Revisar cable, boca de red, switch o servidor DHCP. |
| `IP 169.254` | Ningún servidor DHCP respondió: el problema está fuera de la PC. |
| `Tiene IP pero no tiene gateway` | Configuración incompleta o problema del DHCP. |
| `No responde el gateway` | Revisar cable, switch o router. |
| `Llega al gateway pero no sale a internet` | Firewall, proxy o router. |
| `Hay internet pero falla DNS` | Revisar los servidores DNS. |

## Log

Cada ejecución agrega una línea a `log_red.txt` (en la carpeta del script) con fecha, nombre de la PC, número de serie, IP y resultado:

```
2026-09-24 13:12 | DESKTOP-ULDQS99 | Serie: ABC1234 | 192.168.69.17 | OK: conexion funcionando
```

Se incluye el **número de serie (BIOS)** porque en redes con equipos clonados o con imagen común, muchas PCs comparten el mismo nombre y el nombre solo no alcanza para distinguirlas. En algunos equipos genéricos el serie puede venir con un valor de fábrica tipo `To be filled by O.E.M.`.

Si el script se aloja en un pendrive protegido contra escritura, el log simplemente no se crea y el script sigue funcionando.


## Limitaciones

- **No arregla problemas del servidor DHCP** ni de la infraestructura (switch, cableado, router). Solo repara el lado del cliente.
- **No puede encender** un Wi-Fi apagado por botón físico o modo avión.
- **Corte breve de conexión:** liberar/renovar la IP y reiniciar adaptadores corta la red unos segundos. No lo corras con descargas o sesiones remotas abiertas.
- Algunos antivirus o políticas de empresa pueden bloquear `.bat` en USB o marcarlos por heurística, ya que el script se autoeleva con PowerShell. Podés revisar el código antes de ejecutarlo.

## Aviso

Usar bajo responsabilidad en equipos donde tengas autorización para hacer cambios de red.



# Reparación y diagnóstico de red

Script `.bat` para Windows 10 que repara problemas comunes de conexión y diagnostica dónde está el problema, **sin necesidad de reiniciar la PC**.

## Qué hace

1. **Pide permisos de administrador** automáticamente (se relanza elevado).
2. **Muestra el estado de red anterior** a la reparación (adaptadores, IP, gateway, servidor DHCP, DNS).
3. **Habilita adaptadores de red deshabilitados.**
4. **Asegura que estén corriendo los servicios de red** (DHCP Client, DNS Client, NLA, WLAN AutoConfig, etc.).
5. **Reset de Winsock y de la pila IP** (`netsh winsock reset`, `netsh int ip reset`). Si detecta un adaptador físico con **IP fija**, omite el reset de la pila IP para no perder esa configuración.
6. **Limpia el proxy WinHTTP.**
7. **Limpia cachés** DNS, ARP y NetBIOS.
8. **Libera la IP**, **reinicia los adaptadores** físicos y **renueva la IP**.
9. **Re-registra el DNS.**
10. **Muestra el estado final**, hace pruebas de conectividad y da un **diagnóstico en una línea**.
11. **Guarda un log** (`log_red.txt`) junto al script, con la fecha, el tipo de IP (fija o dinámica) y el resultado.


## Uso

1. Descargar `reparar_red.bat`.
2. Ejecutarlo con doble clic.
3. Aceptar el aviso de Windows que pide permisos de administrador.
4. Esperar a que termine y leer el `RESULTADO` final.
5. Presionar una tecla para cerrar la ventana.


## Diagnóstico

Al final el script hace pruebas contra el gateway, contra internet (`8.8.8.8`) y de resolución DNS (`google.com`), y con eso indica dónde está el problema:

| Resultado | Qué significa |
|---|---|
| `OK: conexion funcionando` | Todo en orden. |
| `SIN IP` | Revisar cable, boca de red, switch o servidor DHCP. |
| `IP 169.254` | Ningún servidor DHCP respondió: el problema está fuera de la PC. |
| `Tiene IP pero no tiene gateway` | Configuración incompleta o problema del DHCP. |
| `No responde el gateway` | Revisar cable, switch o router. |
| `Llega al gateway pero no sale a internet` | Firewall, proxy o router. |
| `Hay internet pero falla DNS` | Revisar los servidores DNS. |

## Log

Cada ejecución agrega una línea a `log_red.txt` (en la carpeta del script) con la fecha, el tipo de IP (`IP fija` o `IP dinamica`) y el resultado del diagnóstico:

```
2026-10-07 13:12 | IP dinamica | OK: conexion funcionando
2026-10-07 13:20 | IP fija | No responde el gateway
```

Si dice `OK`, la conexión quedó funcionando; cualquier otro resultado indica dónde sigue el problema. No se guardan datos del equipo (nombre, número de serie ni IP).

Si el script se aloja en un pendrive protegido contra escritura, el log simplemente no se crea y el script sigue funcionando.


## Limitaciones

- **No arregla problemas del servidor DHCP** ni de la infraestructura (switch, cableado, router). Solo repara el lado del cliente.
- **No puede encender** un Wi-Fi apagado por botón físico o modo avión.
- **Equipos con IP fija:** el script omite el reset de la pila IP para no perder la configuración (el criterio es que algún adaptador físico tenga DHCP desactivado), así que si el problema venía de ahí no lo va a arreglar. El resto de la reparación se ejecuta igual.
- **Proxy:** el paso que limpia el proxy WinHTTP borra un proxy configurado a mano; si tu red lo usa, habrá que volver a cargarlo.
- **Corte breve de conexión:** liberar/renovar la IP y reiniciar adaptadores corta la red unos segundos. No lo corras con descargas o sesiones remotas abiertas.
- Algunos antivirus o políticas de empresa pueden bloquear `.bat` en USB o marcarlos por heurística, ya que el script se autoeleva con PowerShell. Podés revisar el código antes de ejecutarlo.

## Aviso

Usar bajo responsabilidad en equipos donde tengas autorización para hacer cambios de red.

