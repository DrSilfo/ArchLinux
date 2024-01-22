# Arch Linux

[Página Oficial](https://www.archlinux-es.org/), puedes [descargar](https://www.archlinux-es.org/descargar/) la iSO y por medio de la comunidad contar con un soporte.

# Objetivo

Crear una guía que recopile todos los pasos necesarios para construir un entorno de escritorio a partir de una instalación limpia basada en la distribución de Arch Linux.

# Instalación de Arch Linux

## Configuración Maquina Virtual

* Tamaño en disco de 90 GB
* Tamaño de memoría 4GB
* Cantidad de Procesadores 2

## Pre-Instalación

Para lograr el reconocimiento de todos los caracteres, es necesario configurar una distribución temporal del teclado de manera adecuada.

Iniciamos cambiando el teclado que por defecto viene en Inglés a Español, con el comando [loadkeys](https://wiki.archlinux.org/title/Linux_console/Keyboard_configuration#Loadkeys):

```bash
root@archiso ~ # loadkeys es
```
Se recomienda utilizar la conexión por cable en lugar de la conexión inalámbrica, ya que proporciona una mayor estabilidad y velocidad a tu conexión a Internet. Para establecer una conexión por cable, simplemente necesitas conectar el cable Ethernet. Después, puedes hacer un ping para verificar la conexión a Internet.

```bash
root@archiso ~ # ping -c 3 archlinux.org
```
* El parámetro -c 3 establece que se ejecute ping tres veces.
* Por defecto en la ISO habilita el servicio de dhcpcd para el uso de red cableada.

> Nota: Si has tenido problemas al hacer el ping, es probable que hayas conectado el cable Ethernet después de haber iniciado el live USB. Lo más común en esta situación es que el servicio dhcpcd no se haya iniciado correctamente. Por lo tanto, vamos a proceder a iniciar el servicio.

```bash
root@archiso ~ # systemctl start dhcpcd
```
> Ahora verifique que el cable Ethernet está bien conectado y vuelva a hacer un ping.
```bash
root@archiso ~ # ping -c 3 archlinux.org
```
> Ya debería estar recibiendo datos al hacer ping, lo que indica que ya tiene conexión a Intenet, de lo contrario reinicie y vuelva a entrar al live usb para iniciar correctamente los servicios.

## Configuración Inicial

Vamos a configurar el idioma temporal de las herramientas disponibles a nuestro idioma español, sobre todo las de particionado.
```bash
root@archiso ~ # echo "es_ES.UTF-8 UTF-8" > /etc/locale.gen
```
Ahora vamos a generar la configuración regional.
```bash
root@archiso ~ # locale-gen
```
Exportamos la variable LANG para finalizar la configuración regional temporal.
```bash
root@archiso ~ # export LANG=es_ES.UTF-8
```
Sincronizamos el reloj con el comando [timedatectl](https://wiki.archlinux.org/title/System_time):
```bash
root@archiso ~ # timedatectl set-ntp true
```
> Nota: La sincronización es opcional.

**Verificamos el modo de arranque**

Verificamos si la placa base es compatible con **UEFI**, consultando si existe el directorio especificado y mostrando resultado con archivos existentes, caso contrario de no mostrar información ni archivos el arranque solo es compatible con **BIOS/Legacy**.
```bash
root@archiso ~ # ls /sys/firmware/efi/efivars
```
**Tabla de partición (UEFI o BIOS/Legacy)**

Existen dos tablas de particiones disponibles para usar, MBR/dos o GPT
* **MRB/dos** para tarjetas madre compatibles con BIOS/Legacy.
* **GPT** para tarjetas madre compatibles con EFI y UEFI.

> UEFI = Tabla de partición GPT. | BIOS = Tabla de partición MBR/dos.

Para consultar la tabla de particiones que tiene su disco duro donde va a instalar el Sistema Operativo use el siguiente comando.
```bash
root@archiso ~ # fdisk -l
```
* Es importante saber cual es la ruta de nuestro almacenamiento.
* Nuestro caso es /dev/sda: 90Gib con su tabla de partición MBR (dos/msdos)
* Los resultados que terminan en [rom, loop o airoot] pueden ignorarse.
* En este caso /dev/loop0 es la imagen ISO de ArchLinux.

Si usted ve la necesidad de cambiar de una tabla de partición a otra, use una de las siguientes opciones.Tenga en cuenta que este procedimiento eliminará la información del dispositivo de almacenamiento escogido.

Para convertir de MBR a GPT

```bash
root@archiso ~ # parted /dev/sda mklabel gpt
```
Para convertir de GTP a MBR

```bash
root@archiso ~ # parted /dev/sda mklabel msdos
```

Otra opción para consultar la tabla de particiones que tiene su disco duro

```bash
root@archiso ~ # parted -l | egrep "Model|/dev/sd|msdos|gpt"
```
**Disco Duro: **Primero, es importante identificar la estructura de los discos para determinar las rutas y las particiones correspondientes.

Las rutas del disco pueden ser: 

* /dev/sda (sdd o hdd)
* /dev/sdb (sdd o hdd)
* /dev/sdc (Así cambia de letra...)
* /dev/nvme0n1 (veMMC o SD Card)
* /dev/mmcblk0 (veMMC o SD Card)

```bash
root@archiso ~ # lsblk -Spo NAME,MODEL,SIZE
```
**Particiones: **Podrían ser: 

* /dev/sda1
* /dev/sda2
* /dev/sda3
* /dev/nvme0n1p1
* /dev/nvme0n1p2
* /dev/nvme0n1p3
* /dev/mmcblk0p1
* /dev/mmcblk0p2
* /dev/mmcblk0p3

```bash
root@archiso ~ # lsblk
```

## Crea Particiones en el Disco

Primero revisaremos cual es el dispositivo donde se encuentra el disco que vamos a usar con el comando [lsblk](https://wiki.archlinux.org/title/Device_file#lsblk):

```bash
root@archiso ~ # lsblk
```

  En mi caso voy a usar el /dev/sda.

Tenemos que crear 3 particiones, una para los archivos de inicio o [boot](https://wiki.archlinux.org/title/Arch_boot_process), otra donde van a estar instalado Arch Linux, y finalmente otra para el [SWAP](https://wiki.archlinux.org/title/Swap), esta última se puede omitir en caso estes realizando esto en un entorno de "pruebas".

  Nota: Como mejor practica se deberia considerar una para el "/home".

Continuaremos con una estructura sencilla, para crear las particiones ejecutaremos [cfdisk](https://wiki.archlinux.org/title/Fdisk):

```bash
root@archiso ~ # cfdisk
```
ahí seleccionaremos la opción "dos", y luego selecionamos "New"

* Creamos la 1° partición y le asignamos un tamaño de 512M
* Creamos la 2° partición y le asignamos un tamaño de 81,5G
* Creamos la 3° partición y le asignamos un tamaño de 8G

Seleccionada la última partición vamos a "Tipo" y le indicamos la opción "Linux swap".

Finalmente seleccionamos "Escribir" y le ponemos "yes" y validamos con [lsblk](https://wiki.archlinux.org/title/Device_file#lsblk):

```bash
root@archiso ~ # lsblk
```
Luego salimos de la herramienta con la opción "Salir"

## Formatea las Particiones

Para la primera partición ejecutaremos [mkfs](https://wiki.archlinux.org/title/File_systems#Create_a_file_system):

```bash
root@archiso ~ # mkfs.vfat -F 32 /dev/sda1
```

Para la segunda partición (De archivos de sistema) ejecutaremos [mkfs](https://wiki.archlinux.org/title/File_systems#Create_a_file_system): 

```bash
root@archiso ~ # mkfs.ext4  /dev/sda2
```

Para la tercera partición (SWAP) ejecutaremos:

```bash
root@archiso ~ # mkswap  /dev/sda3
```

Para aplicar los cambios ejecutamos:

```bash
root@archiso ~ # swapon
```

## Monta las Particiones

Una vez definidas, creadas y formateadas las particiones debemos montarlas en nuestro sistema.

Montamos la segunda partición en "/mnt" que es nuestro directorio para la instalación de Arch Linux:

```bash
root@archiso ~ # mount /dev/sda2 /mnt
```

Debemos crear el directorio donde estará nuestra partición de inicio, para eso vamos a crear un directorio en la partición previamente montada:
```bash
root@archiso ~ # mkdir /mnt/boot
```

Montamos la primera partición en:

```bash
root@archiso ~ # mount /dev/sda1 /mnt/boot
```

Verificamos que las particiones estén montadas correctamente utilizando [lsblk](https://wiki.archlinux.org/title/Device_file#lsblk):

```bash
root@archiso ~ # lsblk
```

## Instala los paquetes "base"

Una vez montadas las particiones comenzamos la instalación de los paquetes base:

  Nota: Estamos indicando la ruta "/mnt", para la instalación

```bash
root@archiso ~ # pacstrap /mnt linux linux-firmware linux-headers base base-devel grub
```
## Crear [fstab](https://wiki.archlinux.org/title/Fstab)

Este archivo contiene información del montaje de las particiones, para crearlo ejecutamos lo siguiente:

```bash
root@archiso ~ # genfstab -U /mnt > /mnt/etc/fstab
```
## Instalar el [GRUB](https://wiki.archlinux.org/title/GRUB)

Listo, ya que hemos creado el archivo "fstab" y que las particiones estas correctamente configuradas, vamos a ingresar a la instalación base e iniciar con la configuración:

```bash
root@archiso ~ # arch-chroot /mnt
```

Instalamos el grub en el "/dev/sda".

```bash
[root@archiso /]# grub-install /dev/sda
```

Deshabilitar el arranque silencio del grub (Opcional):

```bash
[root@archiso /]# pacman -S vim
[root@archiso /]# vim /etc/default/grub
```
Eliminar la palabra "quiet", debería quedar de la siguiente manera:

```bash
GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3"
```

Ahora crearemos el archivo de configuración

```bash
[root@archiso /]# grub-mkconfig -o /boot/grub/grub.cfg
```
## Instala los paquetes "recomendados"
   
```bash
[root@archiso /]# pacman -S dhcpcd iwd net-tools ifplugd networkmanager reflector xdg-utils xdg-user-dirs
```
> Paquetes adicionales: dialog os-prober mtools dosfstools   

## Habilita los servicios

Es momento de habilitar los servicios que correrán cada que reinicies la máquina.

  * Habilita el manejador de la red.
  * Continua con el servicio de SSH
  
```bash
[root@archiso /]# systemctl enable dhcpcd
[root@archiso /]# systemctl enable NetworkManager
[root@archiso /]# systemctl enable iwd
```
## Instala los paquetes "adicionales"

```bash
[root@archiso /]# pacman -S git wget curl openssh neofetch htop unzip p7zip lsb-release
```

## Configuración de tu zona horaria

Primero vamos a validar la zona horaria.

```bash
[root@archiso /]# echo $(curl https://ipapi.co/timezone)
```

Una vez identificada la zona horaria, creamos un enlace simbolico en "/etc/localtime"

```bash
[root@archiso /]# ln -sf /usr/share/zoneinfo/America/Lima /etc/localtime
```
Definimos la zona horaria según nos defina "https://ipapi.co/timezone"

```bash
[root@archiso /]# timedatectl set-timezone America/Lima
```
Ahora podemos sincronizar el reloj del sistema con el reloj del hardware:

```bash
[root@archiso /]# hwclock -w
```

## Configurar "Localización"

Esto es para indicarle a Arh Linux donde nos ubicamos y cual es el grupo de caracteres que corresponden a tu idioma.

En mi caso voy a utilizar "es_Pe.UTF-8" pero por ejemplo.

  Nota: Puedes habilitar más de un código de localización.
  
Para habilitar el código de localización deseado, edita el siguiente archivo y desconecta la línea donde se encuentra el código deseado.

```bash
[root@archiso /]# vim /etc/locale.gen
```

  Nota: para esto eliminamos "#", que se encuentra delante de cada linea.

Genera la localización en el sistema:

```bash
[root@archiso /]# locale-gen
```

Ahora necesitamos crear estos dos archivos de configuración en nuesta instalación: 

```bash
[root@archiso /]# echo LANG=es_PE.UTF-8 > /etc/locale.conf
[root@archiso /]# echo KEYMAP=es > /etc/vconsole.conf
```

## Configuración de pacman

Está configuración es opcional

```bash
[root@archiso /]# vim /etc/pacman.conf
```
En "Misc options, debemos quitar algunos comentarios eliminando "#", y debería quedar de la siguiente manera:

```bash
#Misc Options
#UseSysLog
Color
#NoProgressBar
CheckSpace
VerbosePkgLists
ParallelDownloads = 5
ILoveCandy
```
Guardamos el archivo.

## Configura la Red

Crear el archivo "hostname", para darle un nombre a tu máquina:

  Ejemplo: gpmpconsulting
  
```bash
[root@archiso /]# echo gpmpconsulting > /etc/hostname
```

Abrimos el archivo "/etc/hosts"

```bash
[root@archiso /]# vim /etc/hosts
```
Y agregamos:

```bash
127.0.0.1  localhost
::1        localhost
127.0.1.1  gpmpconsulting.localhost	gpmpconsulting
```

En esta paso de la instalación es entregarle una contraseña a nuestro root, como ya nos encontramos en nuestra instalación, para cambiar la contraseña escribimos:

```bash
[root@archiso /]# passwd
```

  Nota: En el prompt escribes la contraseña y en el siguiente vuelve a escribir la contraseña para confirmarlo.
  
 ## Configurar las mirror con Reflector

Podremos contar con los mejores mirror con la mejor velocidad de descargar y haciendo uso de un protocolo https.

```bash
[root@archiso /]# reflector --verbose --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```
Podriamos validar con el siguiente comando:

```bash
[root@archiso /]# cat /etc/pacman.d/mirrorlist
```

## Crea el usuario

Durante todo el proceso hemos hecho uso del usuario "root", pero las buenas practicas indican que se debe tener un usuario para la tareas diarias. Creare en mi caso el usuario "drsilfo" y le asignare una contraseña como lo hicimos con el usuario "root".

```bash
[root@archiso /]# useradd -mG wheel drsilfo
[root@archiso /]# passwd drsilfo
```

Ahora debemos darle privilegios de "sudo" y puedas ejecutar comandos como superusuario "root", debemos descomenta la linea que dice "%wheel ALL=(ALL:ALL) ALL".

Para ejecutaremos: 

```bash
[root@archiso /]# EDITOR=vim visudo
```

## Salir de la Instalación y Reinicia la Máquina

Con esto terminamos la instalación, así que solo queda: 

```bash
[root@archiso /]# exit
root@archiso ~ # reboot
```

Finalmente tenemos una instalación limpia...

## Instalación del Xorg Server

Instalamos los siguientes paquetes:

```bash
[root@gpmpconsulting drsilfo]# pacman -S mesa xorg xorg-apps xorg-twm
```
## Instalación del XFC4

Instalamos los siguientes paquetes:

```bash
[root@gpmpconsulting drsilfo]# pacman -S xfce4 xfce4-goodies gvfs network-manager-applet pulseaudio pavucontrol
```
## Instalación del Gestor de Inicio (Lightdm)

Instalamos los siguientes paquetes:

```bash
[root@gpmpconsulting drsilfo]# pacman -S lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings
```

Iniciamos el servicio del Gestor de Inicio:

```bash
[root@gpmpconsulting drsilfo]# systemctl enable lightdm.service
```
## VMWare-Tools

Nos ponemos como root e instalamos los siguientes paquetes:

```bash
[root@gpmpconsulting drsilfo]# pacman -S open-vm-tools xf86-video-vmware xf86-input-vmmouse
```
Luego habilitamos el servicio:

```bash
[root@gpmpconsulting drsilfo]# systemctl enable vmtoolsd
```

# Repositorios

## Repositorios [AUR](https://aur.archlinux.org/)

Instalamos el repositorio, considerar realizar la descarga en una caperta "repositorios" está debe encontrarse en el directorio del usuario ejm: "/home/drfilfo/repositorio"

```bash
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin/
makepkg -si
```
## Repositorios [BLACKARCH](https://blackarch.org/)

Instalamos el repositorio, considerar colocar la descarga en una caperta "repositorios" está debe encontrarse en el directorio del usuario ejm: "/home/drsilfo/repositorio"

```bash
mkdir blackarch
curl -O https://blackarch.org/strap.sh
chmod +x strap.sh
sudo su
./strap.sh
```
