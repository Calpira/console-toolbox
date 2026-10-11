# win-cleanup

![Windows](https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=data:image/svg%2Bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0id2hpdGUiPjxwYXRoIGQ9Ik0wIDBoMTEuNHYxMS40SDB6TTEyLjYgMEgyNHYxMS40SDEyLjZ6TTAgMTIuNmgxMS40VjI0SDB6TTEyLjYgMTIuNkgyNFYyNEgxMi42eiIvPjwvc3ZnPg%3D%3D)
![Batch](https://img.shields.io/badge/Batch-4D4D4D?style=for-the-badge&logo=windowsterminal&logoColor=white)
![Status](https://img.shields.io/badge/learning%20project-blue?style=for-the-badge)

Script `.bat` para Windows 10/11 que limpia cachés, temporales y archivos residuales del sistema y de los usuarios.

> Este proyecto nació como práctica de scripting en Batch y PowerShell, y como compañero del script `apt-cleanup` para Linux. **Borra archivos sin pedir confirmación**, por eso se recomienda revisar el código antes de ejecutarlo.

## Qué hace

El script ejecuta de manera secuencial las siguientes tareas de mantenimiento:

1. **Pide permisos de administrador** automáticamente (se relanza elevado con UAC).
2. **Muestra el espacio libre en disco antes** de empezar.
3. **Limpia la caché de Windows Update** (`SoftwareDistribution\Download`), deteniendo y reiniciando los servicios `wuauserv` y `bits`.
4. **Elimina componentes antiguos** del sistema (`dism /startcomponentcleanup /resetbase`) para reducir el tamaño de `WinSxS`.
5. **Repara la imagen del sistema** (`dism /restorehealth`) y **verifica archivos dañados** (`sfc /scannow`).
6. **Purga registros de eventos** (`wevtutil cl` en cada log).
7. **Limpia temporales del sistema** (`%TEMP%`, `%windir%\Temp`, `%windir%\Prefetch`).
8. **Limpia la caché de cada usuario** en `C:\Users`: temporales, miniaturas/iconos, y caché de Chrome y Edge.
9. **Vacía la papelera de reciclaje** de todos los usuarios.
10. **Ejecuta el Liberador de espacio en disco** (`cleanmgr /sagerun:1`) en modo silencioso.
11. **Muestra el espacio libre final** y cuántos MB se liberaron.

## Requisitos

- Windows 10 o Windows 11
- PowerShell disponible (viene por defecto)
- Permisos de administrador (el script los pide solo)
- `dism`, `sfc`, `cleanmgr`, `wevtutil` (todos vienen con Windows)

## Descarga y uso

Descargá solo el script:  -------------------------------------------------



> También podés abrir el archivo en GitHub, tocar **Raw** y guardarlo con clic derecho → *Guardar como*.

1. Ejecutarlo con doble clic.
2. Aceptar el aviso de Windows que pide permisos de administrador.
3. Esperar a que termine (puede tardar varios minutos por `dism` y `sfc`).
4. Leer el resumen final con el espacio liberado.



## Avisos

- **No pide confirmación:** apenas se ejecuta, empieza a borrar. Los servicios de Windows Update se detienen y reinician de forma automática.
- **La papelera se vacía de forma definitiva:** lo que haya en ella no se puede recuperar.
- **Las sesiones de los navegadores NO se pierden:** solo se borra la subcarpeta `Cache` de Chrome/Edge, que es 100% regenerable. Cookies, contraseñas, historial y marcadores **no se tocan**.
- **Primera navegación más lenta:** al borrar la caché de los navegadores, la primera visita a cada web tarda un poco más hasta que se vuelva a llenar.
- **Navegadores abiertos:** si Chrome o Edge están abiertos durante la limpieza, algunos archivos de caché quedan bloqueados y no se borran. No es un error, simplemente se limpian la próxima vez que se ejecute con ellos cerrados.
- **`dism /resetbase` es irreversible:** elimina los componentes antiguos de Windows Update. Después de esto **no podés desinstalar actualizaciones ya instaladas** (solo afecta a las que ya estaban aplicadas, no a futuras).
- **`sfc /scannow` puede tardar bastante** en equipos con discos lentos (HDD). Es normal y no está colgado.
- **Algunos antivirus o políticas de empresa** pueden bloquear `.bat` en USB o marcarlos por heurística, ya que el script se autoeleva con PowerShell. Podés revisar el código antes de ejecutarlo.
- Usar bajo responsabilidad en equipos donde tengas autorización para hacer cambios.
- **Compatible con Windows 10 y 11.** En Windows 11 el comando `wmic` está obsoleto, por eso se usa PowerShell para leer el disco.
