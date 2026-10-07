# apt-cleanup
 
![Linux](https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black)
![Bash](https://img.shields.io/badge/Bash-4EAA25?style=for-the-badge&logo=gnubash&logoColor=white)
![Status](https://img.shields.io/badge/learning%20project-blue?style=for-the-badge)
 
Script de limpieza para sistemas basados en Debian/Ubuntu (probado en Linux Mint).
 
> Este proyecto nació con **fines de estudio** de scripting en Bash y automatización local. Si bien realiza tareas estándar de mantenimiento, **borra archivos sin pedir confirmación**, por lo que se recomienda revisar el código antes de ejecutarlo.
 
 
## Qué hace
 
El script ejecuta de manera secuencial las siguientes tareas de administración de sistemas:
 
- Limpia la caché de paquetes de APT (`apt clean`, `apt autoclean`)
- Elimina paquetes huérfanos (`apt autoremove --purge`)
- Repara paquetes pendientes (`dpkg --configure -a`, `apt --fix-broken install`)
- Purga logs de más de 30 días (`journalctl --vacuum-time`)
- Vacía la caché (`~/.cache`) de los usuarios con carpeta en `/home`
- Borra las miniaturas guardadas
- Vacía la papelera de reciclaje de los usuarios con carpeta en `/home`
- Muestra el espacio en disco liberado al finalizar


## Requisitos
 
- Distro basada en Debian/Ubuntu
- systemd
- Permisos de administrador (`sudo`)

  
## Descarga y uso
 
Descargá solo el script:
 
```
curl -O https://raw.githubusercontent.com/Calpira/console-toolbox/main/apt-cleanup/apt-cleanup.sh
chmod +x apt-cleanup.sh
```
 
> También podés abrir el archivo en GitHub, tocar **Raw** y guardarlo con clic derecho → *Guardar como*.
 
 
desde la misma carpeta donde lo descargaste:
```
sudo ./apt-cleanup.sh
```
 
 
## Advertencias
 
- **No pide confirmación:** apenas se ejecuta, empieza a borrar. Los paquetes se instalan y quitan en modo no interactivo.
- **La papelera se vacía de forma definitiva:** lo que haya en ella no se puede recuperar.
- **Solo usuarios en `/home`:** no toca `/root` ni usuarios con la carpeta personal en otra ubicación.
- **El espacio liberado se mide solo sobre `/`:** si `/home` está en otra partición, el número final no refleja lo que se limpió ahí.


## Comportamiento en Observación
 
En algunos casos, mientras el script corre, se ha detectado de forma aislada que la terminal puede dejar de responder temporalmente al teclado durante el proceso. El script finaliza sus tareas correctamente y el entorno vuelve a la normalidad reiniciando el gestor de ventanas (`Ctrl+Alt+Esc`).
