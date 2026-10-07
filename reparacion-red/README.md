# Reparación y diagnóstico de red


![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=data:image/svg%2Bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0id2hpdGUiPjxwYXRoIGQ9Ik0wIDBoMTEuNHYxMS40SDB6TTEyLjYgMEgyNHYxMS40SDEyLjZ6TTAgMTIuNmgxMS40VjI0SDB6TTEyLjYgMTIuNkgyNFYyNEgxMi42eiIvPjwvc3ZnPg%3D%3D)
![Batch](https://img.shields.io/badge/Batch-4D4D4D?style=for-the-badge&logo=windowsterminal&logoColor=white)
![Status](https://img.shields.io/badge/learning%20project-blue?style=for-the-badge)



Script `.bat` para Windows 10 que repara problemas comunes de conexión y diagnostica dónde está el problema.

> Este proyecto nació para resolver un problema puntual de **conflictos de IP en una red de trabajo**, y también como práctica de scripting en Batch y PowerShell. Realiza cambios en la configuración de red del equipo, por eso se recomienda revisar el código antes de ejecutarlo.

## Qué hace

1. **Pide permisos de administrador** automáticamente (se relanza elevado).
2. **Muestra el estado de red anterior** a la reparación (adaptadores, IP, gateway, servidor DHCP, DNS) y hace una **primera prueba de conectividad**.
3. **Habilita adaptadores de red deshabilitados.**
4. **Asegura que estén corriendo los servicios de red** (DHCP Client, DNS Client, NLA, WLAN AutoConfig, etc.).
5. **Reset de Winsock y de la pila IP** (`netsh winsock reset`, `netsh int ip reset`). Si detecta un adaptador físico con **IP fija**, omite el reset de la pila IP para no perder esa configuración.
6. **Limpia el proxy WinHTTP.**
7. **Limpia cachés** DNS, ARP y NetBIOS.
8. **Libera la IP**, **reinicia los adaptadores** físicos y **renueva la IP**.
9. **Re-registra el DNS.**
10. **Muestra el estado final**, hace pruebas de conectividad y da un **diagnóstico en una línea**.
11. **Guarda un log** (`log_red.txt`) junto al script, con la fecha, el tipo de IP (fija o dinámica) y el diagnóstico de antes y después.


## Uso

1. Descargar `reparar_red.bat`.
2. Ejecutarlo con doble clic.
3. Aceptar el aviso de Windows que pide permisos de administrador.
4. Esperar a que termine y leer el `RESULTADO` final.
5. Presionar una tecla para cerrar la ventana.


## Diagnóstico

El script hace pruebas contra el gateway, contra internet (`8.8.8.8`) y de resolución DNS (`google.com`), una vez antes de reparar y otra al final, y con eso indica dónde está el problema:

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

Cada ejecución agrega una línea a `log_red.txt` (en la carpeta del script) con la fecha, el tipo de IP (`IP fija` o `IP dinamica`) y el diagnóstico de antes y después de reparar:

```
2026-10-07 13:12 | IP dinamica | Antes: Hay internet pero falla DNS | Despues: OK: conexion funcionando
2026-10-07 13:20 | IP fija | Antes: No responde el gateway | Despues: No responde el gateway
```

`Antes` muestra el síntoma original. Si `Despues` dice `OK`, la conexión quedó funcionando; si no, indica dónde sigue el problema. No se guardan datos del equipo (nombre, número de serie ni IP).

Si el script se aloja en un pendrive protegido contra escritura, el log simplemente no se crea y el script sigue funcionando.


## Avisos

- **Equipos con IP fija:** el script omite el reset de la pila IP para no perder la configuración (el criterio es que algún adaptador físico tenga DHCP desactivado), así que si el problema venía de ahí no lo va a arreglar. El resto de la reparación se ejecuta igual.
- **Proxy:** el paso que limpia el proxy WinHTTP borra un proxy configurado a mano; si tu red lo usa, habrá que volver a cargarlo.
- **Corte breve de conexión:** liberar/renovar la IP y reiniciar adaptadores corta la red unos segundos. No lo corras con descargas o sesiones remotas abiertas.
- Algunos antivirus o políticas de empresa pueden bloquear `.bat` en USB o marcarlos por heurística, ya que el script se autoeleva con PowerShell. Podés revisar el código antes de ejecutarlo.
- Usar bajo responsabilidad en equipos donde tengas autorización para hacer cambios de red.

