# Arch Linux

[Página Oficial](https://www.archlinux-es.org/), puedes [descargar](https://www.archlinux-es.org/descargar/) la iSO y por medio de la comunidad contar con un soporte.

# Objetivo

Crear una guía que recopile todos los pasos necesarios para construir un entorno de escritorio a partir de una instalación limpia basada en la distribución de Arch Linux.

# Instalación de Arch Linux

## Configuración Inicial

Iniciamos cambiando el teclado que por defecto viene en Inglés a Español, con el comando [loadkeys](https://wiki.archlinux.org/title/Linux_console/Keyboard_configuration#Loadkeys):

```bash
loadkeys es
```

Sincronizamos el reloj con el comando [timedatectl](https://wiki.archlinux.org/title/System_time):

```bash
timedatectl set-ntp true
```

Instalaremos previamente un paquete que se llama [Reflector](https://wiki.archlinux.org/title/Reflector), con el uso de [pacman](https://wiki.archlinux.org/title/Pacman):

```bash
pacman -Syy reflector
```

Teniendo instalado el paquete [Reflector](https://wiki.archlinux.org/title/Reflector), vamos a selecionar el servidor más cercano para instalar los paquetes [Mirror](https://wiki.archlinux.org/title/Mirrors), pero previamos necesitamos conocer cuales son los disponibles:

```bash
reflector --list-countries | more
```

Una vez identificado el país y su codigo que se encuentre mas cercano, ejecutamos lo siguiente:

```bash
reflector -c "Ecuador" -a 6 --sort rate --save /etc/pacman.d/mirrorlist
```

Ahora actualizaremos los pquetes:

```bash
pacman -Syyy
```

## Crea Particiones en el Disco

Primero revisaremos cual es el dispositivo donde se encuentra el disco que vamos a usar con el comando [lsblk](https://wiki.archlinux.org/title/Device_file#lsblk):

```bash
lsblk
```

  En mi caso voy a usar el /dev/sda.

Tenemos que crear 3 particiones, una para los archivos de inicio o [boot](https://wiki.archlinux.org/title/Arch_boot_process), otra donde van a estar instalado Arch Linux, y finalmente otra para el [SWAP](https://wiki.archlinux.org/title/Swap), esta última se puede omitir en caso estes realizando esto en un entorno de "pruebas".

  Nota: Como mejor practica se deberia considerar una para el "/home".

Continuaremos con una estructura sencilla, para crear las particiones ejecutaremos [cfdisk](https://wiki.archlinux.org/title/Fdisk):

```bash
cfdisk
```
ahí seleccionaremos la opción "dos", y luego selecionamos "New"

Creamos la 1° partición y le asignamos un tamaño a la partición de 512M, a la 2° partición le asignamos un tamaño de 15GB y la 3° partición y le asignamos un tamaño de 4.5GB.

Seleccionada la última partición vamos a "Type" y le indicamos la opción "Linux swap".

Finalmente seleccionamos "Write" y le ponemos "yes" y validamos con [lsblk](https://wiki.archlinux.org/title/Device_file#lsblk):

```bash
lsblk
```

## Formatea las Particiones

Para la primera partición ejecutaremos [mkfs](https://wiki.archlinux.org/title/File_systems#Create_a_file_system):

```bash
mkfs.vfat -F 32 /dev/sda1
```

Para la segunda partición (De archivos de sistema) ejecutaremos [mkfs](https://wiki.archlinux.org/title/File_systems#Create_a_file_system): 

```bash
mkfs.ext4  /dev/sda2
```

Para la tercera partición (SWAP) ejecutaremos:

```bash
mkswap  /dev/sda3
```

Para aplicar los cambios ejecutamos:

```bash
swapon
```

## Monta las Particiones

Una vez definidas, creadas y formateadas las particiones debemos montarlas en nuestro sistema.

Montamos la segunda partición en "/mnt" que es nuestro directorio para la instalación de Arch Linux:

```bash
mount /dev/sda2 /mnt
```

Debemos crear el directorio donde estará nuestra partición de inicio, para eso vamos a crear un directorio en la partición previamente montada:
```bash
mkdir /mnt/boot
```

Montamos la primera partición en:

```bash
mount /dev/sda1 /mnt/boot
```

Verificamos que las particiones estén montadas correctamente utilizando [lsblk](https://wiki.archlinux.org/title/Device_file#lsblk):

```bash
lsblk
```

### Instala los paquetes "base"

Una vez montadas las particiones comenzamos la instalación de los paquetes base:

  Nota: Estamos indicando la ruta "/mnt", para la instalación

```bash
pacstrap /mnt linux linux-firmware base base-devel grub vim
```
### Crear [fstab](https://wiki.archlinux.org/title/Fstab)

Este archivo contiene información del montaje de las particiones, para crearlo ejecutamos lo siguiente:

```bash
genfstab -U /mnt > /mnt/etc/fstab
```

### Instalar el [GRUB](https://wiki.archlinux.org/title/GRUB)

Listo, ya que hemos creado el archivo "fstab" y que las particiones estas correctamente configuradas, vamos a ingresar a la instalación base e iniciar con la configuración:

```bash
arch-chroot /mnt
```

Instalamos el grub en el "/dev/sda".

```bash
grub-install /dev/sda
```

Ahora crearemos el archivo de configuración

```bash
grub-mkconfig -o /boot/grub/grub.cfg
```

### Configuración de tu zona horaria

Primero vamos a ver un listado de las zonas horarias disponibles.

  Nota: La zona horaria en mi caso es "Bogota", sustituye "Bogota" por la ciudad que te corresponda.

```bash
timedatectl list-timezones | grep Bogota
```

Una vez identificada la zona horaria, creamos un enlace simbolico en "/etc/localtime"

```bash
ln -sf /usr/share/zoneinfo/America/Chicago /etc/localtime
```

Ahora podemos sincronizar el reloj del sistema con el reloj del hardware:

```bash
hwclock --systohc
```

### Configura tu "Localización"

Esto es para indicarle a Arh Linux donde nos ubicamos y cual es el grupo de caracteres que corresponden a tu idioma.

En mi caso voy a utilizar "es_Pe.UTF-8" pero por ejemplo.

  Nota: Puedes habilitar más de un código de localización.
  
Para habilitar el código de localización deseado, edita el siguiente archivo y desconecta la línea donde se encuentra el código deseado.

```bash
vim /etc/locale.gen
```

  Nota: para esto eliminamos "#", que se encuentra delante de cada linea.

Genera la localización en el sistema:

```bash
locale-gen
```

Ahora necesitamos crear estos dos archivos de configuración en nuesta instalación: 

```bash
echo LANG=es_PE.UTF-8 > /etc/locale.conf
echo KEYMAP=es > /etc/vconsole.conf
```

### Configura la Red

Crear el archivo "hostname", para darle un nombre a tu máquina:

  Ejemplo: archcat
  
```bash
echo archcat > /etc/hostname
```

Abrimos el archivo "/etc/hosts"

```bash
vim /etc/hosts
```
Y agregamos:

```bash
127.0.0.1	localhost
::1		    localhost
127.0.1.1	archcat.localhost	archcat
```

### Creamos una contraseña para el root

En esta paso de la instalación es entregarle una contraseña a nuestro root, como ya nos encontramos en nuestra instalación, para cambiar la contraseña escribimos:

```bash
passwd
```

  Nota: En el prompt escribes la contraseña y en el siguiente vuelve a escribir la contraseña para confirmarlo.
  
 ### Instala los paquetes finales
  
 Es momento de instalar nuestro "boot loader", y paquetes finales antes de reiniciar.
  
```bash
pacman -S networkmanager network-manager-applet wpa_supplicant dialog os-prober mtools dosfstools linux-headers reflector openssh git xdg-utils xdg-user-dirs
```

### Habilita los servicios

Es momento de habilitar los servicios que correrán cada que reinicies la máquina.

  1.- Habilita el manejador de la red.
  2.- Continua con el servicio de SSH
  
```bash
systemctl enable NetworkManager
systemctl enable sshd
```

### Crea el usuario

Durante todo el proceso hemos hecho uso del usuario "root", pero las buenas practicas indican que se debe tener un usuario para la tareas diarias. Creare en mi caso el usuario "drsilfo" y le asignare una contraseña como lo hicimos con el usuario "root".

```bash
useradd -mG wheel drsilfo
passwd drsilfo
```

Ahora debemos darle privilegios de "sudo" y puedas ejecutar comandos como superusuario "root", debemos descomenta la linea que dice "%wheel ALL=(ALL:ALL) ALL".

Para ejecutaremos: 

```bash
EDITOR=vim visudo
```

### Salir de la Instalación y Reinicia la Máquina

Con esto terminamos la instalación, así que solo queda: 

```bash
exit
reboot
```

Finalmente tenemos una instalación limpia...
