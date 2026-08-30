# 🐧 Guía de Instalación: Arch Linux con Hyprland en VMware

[![Arch Linux](https://img.shields.io/badge/Arch_Linux-1793D1?style=for-the-badge&logo=arch-linux&logoColor=white)](https://archlinux.org/)
[![Hyprland](https://img.shields.io/badge/Hyprland-55B1F3?style=for-the-badge&logo=hyprland&logoColor=white)](https://hyprland.org/)
[![VMware](https://img.shields.io/badge/VMware-607078?style=for-the-badge&logo=vmware&logoColor=white)](https://www.vmware.com/)

Guía paso a paso para desplegar **Arch Linux** desde cero en un entorno virtualizado **VMware Workstation / Player**, configurando un entorno de escritorio moderno, fluido y estético basado en **Wayland + Hyprland**.

---

## 🌐 Enlaces Útiles

* 🌐 [Sitio Oficial de Arch Linux](https://archlinux.org/)
* 📦 [Descarga de ISO Oficial](https://archlinux.org/download/)
* 📖 [Wiki Oficial de Arch Linux](https://wiki.archlinux.org/)
* 💧 [Documentación de Hyprland](https://wiki.hyprland.org/)

---

## 🎯 Objetivos de la Guía

* [x] Instalación limpia y optimizada de la base de Arch Linux bajo arquitectura BIOS/MBR.
* [x] Creación de un usuario no-root con privilegios `sudo`.
* [x] Integración completa con **VMware Guest Utilities** (copiar/pegar, resolución dinámica).
* [x] Despliegue funcional de **Hyprland (Wayland)** y utilidades esenciales (Kitty, Waybar, Rofi-wayland).
* [x] Gestor de inicio de sesión gráfico (`greetd` + `tuigreet`).

---

## 💻 Requisitos Sugeridos para la Máquina Virtual

> [!IMPORTANT]
> Es **imprescindible** marcar la casilla **"Accelerate 3D graphics"** en los ajustes de pantalla (*Display*) de VMware para que Hyprland funcione correctamente.

| Recurso | Mínimo | Recomendado |
| :--- | :--- | :--- |
| **Disco Duro** | 30 GB | **100 GB** (Dinámico) |
| **Memoria RAM**| 2 GB | **4 GB - 8 GB** |
| **Procesadores**| 2 núcleos | **4 núcleos** |
| **Red** | NAT | **NAT / Bridge** |
| **Gráficos** | Aceleración 3D deshabilitada | **Aceleración 3D Habilitada** |

---

## 🧬 01. Preinstalación

⌨️ Configurar distribución del teclado (Español)
```bash
loadkeys es
```

🌐 Verificar conexión a Internet

```bash
ping -c 3 archlinux.org
```

⏰ Sincronizar reloj del sistema

```bash
timedatectl set-ntp true
```

## 📀 02. Particionado del Disco

Verificar discos disponibles:

```bash
lsblk
```
Esquema sugerido (100 GB):

| Partición   | Punto de Montaje | Tamaño  | Tipo FS | Tipo Partición |
| ----------- | ---------------- | ------- | ------- | -------------- |
| `/dev/sda1` | `/boot`          | 1 GB    | ext4    | Linux          |
| `/dev/sda2` | `swap`           | 4 GB    | swap    | Linux swap     |
| `/dev/sda3` | `/`              | \~95 GB | ext4    | Linux          |

Crear tabla y particiones

```bash
wipefs -a /dev/sda
cfdisk /dev/sda
```
> [!IMPORTANT]
> Seleccionar "dos" (MBR).

Formatear y activar particiones:

```bash
mkfs.exr4 /dev/sda1
mkswap /dev/sda2
swapon /dev/sda2
mkfs.ext4 /dev/sda3
```
🧠 swapon: Se utiliza para activar y administrar el espacio de swap en Linux.

## 📂 03. Montaje de Estructura de Directorios

```bash
mount /dev/sda3 /mnt
mkdir -p /mnt/boot
mount /dev/sda1 /mnt/boot
```
## 📥 04. Instalación del Sistema Base

Instalación del kernel, firmware, herramientas de compilación y editores esenciales:

```bash
pacstrap /mnt base base-devel linux linux-firmware linux-headers grub vim nano
```
Generar tabla de montaje `fstab`:

```bash
genfstab -U /mnt >> /mnt/etc/fstab
```
💡Nota: /mnt/etc/fstab contiene la configuración de los sistemas de archivos que Linux debe montar automáticamente durante el arranque.

## 🛫 05. Configuración del Sistema (`arch-chroot`)

Entrar al sistema recién instalado:
```bash
arch-chroot /mnt
```
🌐 Zona Hoaria y Localización

```bash
ln -sf /usr/share/zoneinfo/America/Lima /etc/localtime
hwclock --systohc

echo "es_PE.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

echo "LANG=es_PE.UTF-8" > /etc/locale.conf
echo "KEYMAP=es" > /etc/vconsole.conf
```

💻 Hostname y Red Local

```bash
echo archcat > /etc/hostname
```

Configurar `/etc/hosts`:

```bash
127.0.0.1   localhost
::1         localhost
127.0.1.1   archcat.local archcat
```
🔐 Contraseña de Root y Creación de Usuario

Establecer clave de root:
```bash
passwd
```
Crear usuario estándar:
```bash
useradd -m -G wheel -s /bin/bash drsilfo
passwd drsilfo
```
Dar permisos Sudo:
```bash
EDITOR=vim visudo
```
💡 Descomentar la línea `%wheel ALL=(ALL:ALL) ALL`

## 📦 06. Servicios de Red y Paquetes Esenciales
```bash
pacman -S networkmanager openssh reflector net-tools xdg-utils xdg-user-dirs git wget curl unzip p7zip lsb-release file kitty eog xarchiver mtools dosfstools

systemctl enable NetworkManager
systemctl enable sshd
```
⚙️ Optimización de `pacman.conf` (Opcional)
Edita `/etc/pacman.conf`
```bash
vim /etc/pacman.conf
```
> [!IMPORTANT]
> Asegúrate de tener descomentadas las siguientes opciones:
```bash
Color
CheckSpace
VerbosePkgLists
ParallelDownloads = 5
ILoveCandy
```
## 🚀 07. Instalación del Cargador de Arranque (GRUB)
```bash
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
```
## 🔄 08. Salida del Chroot y Primer Reinicio
```bash
exit
umount -R /mnt
reboot
```
## 🖥️ 09. Integración con VMware Tools
Inicia sesión con tu usuario `drsilfo` y ejecuta:
```bash
sudo pacman -S open-vm-tools xf86-video-vmware xf86-input-vmmouse gtkmm3 mesa
sudo systemctl enable vmtoolsd
sudo systemctl start vmtoolsd
```
## 🪟 10. Instalación del Entorno Hyprland (Wayland)
Instalación de gestor de ventanas, controladores gráficos y herramientas del entorno:
```bash
sudo pacman -S hyprland qt5-wayland qt6-wayland xdg-desktop-portal-hyprland polkit-kde-agent waybar rofi-wayland dunst grim slurp wl-clipboard swaylock swayidle
```
## 🔐 11. Configuración del Gestor de Inicio (`greetd` + `tuigreet`)
Instalación de `greetd`:
```bash
sudo pacman -S greetd greetd-tuigreet
```
Configuración de la sesión en `/etc/greetd/config.toml`:
```bash
sudo vim /etc/greetd/config.toml
```
Reemplaza la sección `[default_session]` por:
```bash
[terminal]
vt = 1

[default_session]
command = "tuigreet --time --cmd Hyprland"
user = "greeter"
```
Habilitar el servicio de inicio de sesión: 
```bash
sudo systemctl enable greetd
```
## 🛠️ 12. Gestores de Paquetes AUR (Opcional)
Instalación de `paru` (Recomendado):
```bash
git clone [https://aur.archlinux.org/paru-bin.git](https://aur.archlinux.org/paru-bin.git)
cd paru-bin
makepkg -si
cd .. && rm -rf paru-bin
```
Alternativa `yay`:
```bash
git clone [https://aur.archlinux.org/yay.git](https://aur.archlinux.org/yay.git)
cd yay
makepkg -si
cd .. && rm -rf yay
```
## 🏁 13. Finalización
Reinicia el sistema para ingresar directamente mediante `tuigreet` a tu nuevo entorno Hyprland:
```bash
sudo reboot
```
## 🛡️ Anexo: Herramientas de Ciberseguridad (Opcional)
> [!WARNING]
> La adición de repositorios de terceros como **BlackArch** puede reemplazar librerías del sistema y afectar la estabilidad del entorno gráfico Hyprland. Se recomienda instalar únicamente las herramientas específicas que necesites vía AUR o contenedores.

Crear directorio de trabajo
```bash
mkdir -p ~/repositorio/blackarch && cd ~/repositorio/blackarch
```
Descargar y verificar el script oficial
```bash
curl -O https://blackarch.org/strap.sh
chmod +x strap.sh
```
Ejecutar el script con privilegios elevados
```bash
sudo ./strap.sh
```
