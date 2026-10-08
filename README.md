# console-toolbox

![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Windows][windows-badge]
![Status](https://img.shields.io/badge/learning%20project-blue?style=for-the-badge)
![Last Commit](https://img.shields.io/github/last-commit/Calpira/console-toolbox?style=for-the-badge)

Monorepositorio para guardar y ordenar utilidades de consola para Linux y Windows.

> Son proyectos hechos con **fines de estudio** y para resolver problemas puntuales. Varios de ellos modifican la configuración del sistema o borran archivos, por lo que se recomienda revisar el código antes de ejecutarlos.

Cada herramienta tiene su propia carpeta, con un README que explica en detalle qué hace y cómo se usa.


## Linux

| Herramienta | Qué hace | Descarga |
|---|---|---|
| [apt-cleanup](apt-cleanup/) | Limpieza de caché de paquetes, paquetes huérfanos, logs, caché de usuarios y papelera en sistemas Debian/Ubuntu. | [apt-cleanup.sh](https://raw.githubusercontent.com/Calpira/console-toolbox/main/apt-cleanup/apt-cleanup.sh) |


## Windows

| Herramienta | Qué hace | Descarga |
|---|---|---|
| [reparar_red](reparacion-red/) | Repara y diagnostica problemas comunes de conexión de red. | [reparar_red.bat](https://raw.githubusercontent.com/Calpira/console-toolbox/main/reparacion-red/reparar_red.bat) |


## Cómo descargar un script

No hace falta clonar todo el repositorio. Podés abrir el link de **Descarga** y guardar el archivo con clic derecho → *Guardar como* (en Windows, verificá que el nombre termine en `.bat` y no en `.txt`), o bajarlo desde la consola con `curl -O` y el mismo link. En cada carpeta está explicado con el comando exacto.


[windows-badge]: https://img.shields.io/badge/Windows-0078D6?style=for-the-badge&logo=data:image/svg%2Bxml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCIgZmlsbD0id2hpdGUiPjxwYXRoIGQ9Ik0wIDBoMTEuNHYxMS40SDB6TTEyLjYgMEgyNHYxMS40SDEyLjZ6TTAgMTIuNmgxMS40VjI0SDB6TTEyLjYgMTIuNkgyNFYyNEgxMi42eiIvPjwvc3ZnPg%3D%3D
