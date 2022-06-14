# Arch Linux

Desde su [Página Oficial](https://www.archlinux-es.org/), puedes descargar la iSO y por medio de la comunidad contar con un soporte.

# Objetivo

Crear una guía que recopile todos los pasos necesarios para construir un entorno de escritorio a partir de una instalación limpia basada en la distribución de Arch Linux.

# Instalación de Archlinux

## Configuración Inicial

Iniciamos cambiando el teclado que por defecto viene en Inglés a Español:

```bash
loadkeys es
```

Sincronizamos el reloj:

```bash
timedatectl set-ntp true
```

Instalaremos previamente un paquete que se llama [Reflector](https://wiki.archlinux.org/title/Reflector):

```bash
pacman -Syy reflector
```

Teniendo instalado el paquete [Reflector](https://wiki.archlinux.org/title/Reflector), vamos a selecionar el servidor más cercano para instalar los paquetes (Mirror), pero previamos necesitamos conocer cuales son los disponibles:

```bash
reflector --list-countries | more
```

Una vez identificado el país y su codigo que se encuentre mas cercado, ejecutamos lo siguiente:

```bash
reflector -c "Ecuador" -a 6 --sort rate --save /etc/pacman.d/mirrorlist
```

Ahora actualizaremos los pquetes:

```bash
pacman -Syyy
```

## Crea Particiones en el Disco

Primero revisaremos cual es el dispositivo donde se encuentra el disco que vamos a usar:

```bash
lsblk
```

