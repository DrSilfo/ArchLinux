# 🐧 Guía de Instalación de Arch Linux en VMware con Hyprland

## 🌐 Enlaces Útiles

- [Sitio Oficial Arch Linux](https://www.archlinux-es.org/)
- [Descarga de la ISO](https://www.archlinux-es.org/descargar/)
- [Wiki Oficial de Arch Linux](https://wiki.archlinux.org/)

---

## 🎯 Objetivo

Instalar **Arch Linux** desde cero en una máquina virtual **VMware**, configurando un entorno moderno con **Hyprland**, servicios esenciales, usuario no-root y soporte para VMware.

---

## 📦 Requisitos de la Máquina Virtual

- **Disco duro:** 90 GB
- **Memoria RAM:** 4 GB
- **Procesadores:** 2 núcleos
- **Red:** Conexión por cable (preferido)

---

## 🧩 1. Pre-Instalación

### ⌨️ Configurar teclado a Español

```bash
loadkeys es
```
### 🌐 Verificar conexión a Internet
```bash
ping -c 3 archlinux.org
```
Si falla:
```bash
systemctl start dhcpcd
```
## 🛠️ 2. Configuración Inicial
```bash
echo "es_ES.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
export LANG=es_ES.UTF-8
timedatectl set-ntp true
```
## 💽 3. Particionado del Disco
```bash
lsblk
```
Crear particiones con cgdisk (Type: gpt)
- `/dev/sda1` → 512M (boot)
- `/dev/sda2` → 81.5G (sistema)
- `/dev/sda3` → 8G (swap)
Formatear particiones
```bash
mkfs.vfat -F 32 /dev/sda1
mkfs.ext4 /dev/sda2
mkswap /dev/sda3
swapon /dev/sda3
```
## 📂 4. Montaje de Particiones
```bash
mount /dev/sda2 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
```
## 📥 5. Instalación del Sistema Base
```bash
pacstrap /mnt base base-devel linux linux-firmware linux-headers grub vim
```
Crear fstab
```bash
genfstab -U /mnt > /mnt/etc/fstab
```
## 🧳 6. Ingresar al sistema instalado
```bash
arch-chroot /mnt
```
## ⚙️ 7. Configuración del Sistema
Instalar y configurar GRUB
```bash
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
```
Opcional:
```bash
vim /etc/default/grub
# GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3"
```
Instalar paquete de red
```bash
pacman -S dhcpcd iwd net-tools ifplugd networkmanager reflector xdg-utils xdg-user-dirs
```
Habilitar servicios
```bash
systemctl enable NetworkManager
systemctl enable iwd
```
Paquetes adicionales
```bash
pacman -S git wget curl openssh neofetch htop unzip p7zip lsb-release
```
Configurar zona horaria
```bash
ln -sf /usr/share/zoneinfo/America/Lima /etc/localtime
timedatectl set-timezone America/Lima
hwclock -w
```
Localización
```bash
vim /etc/locale.gen
# Descomenta es_PE.UTF-8
locale-gen
echo LANG=es_PE.UTF-8 > /etc/locale.conf
echo KEYMAP=es > /etc/vconsole.conf
```
Configuración de Pacman (Opcional)
```bash
vim /etc/pacman.conf
# Activar:
Color
CheckSpace
VerbosePkgLists
ParallelDownloads = 5
ILoveCandy
```
## 🌐 8. Configurar red y hostname
```bash
echo archcat > /etc/hostname
```
Editar /etc/hosts:
```bash
127.0.0.1   localhost
::1         localhost
127.0.1.1   archcat	archcat
```
Contraseña del root
```bash
passwd
```
## 🌍 9. Configurar Mirrorlist
```bash
reflector --verbose --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```
## 👤 10. Crear usuario
```bash
useradd -mG wheel drsilfo
passwd drsilfo
EDITOR=vim visudo
# Descomenta: %wheel ALL=(ALL:ALL) ALL
```
## 🔁 11. Salir y reiniciar
```bash
exit
reboot
```
---
### 🎨 Instalación de Hyprland (Wayland)
Desde ahora, ejecutar como usuario drsilfo o como root según sea necesario.
## ⚙️ Requisitos previos
```bash
sudo pacman -S git kitty
```
No olvides establecer Kitty como tu terminal por defecto en Hyprland. Puedes hacerlo añadiendo en `~/.config/hypr/hyprland.conf`:
```bash
exec-once = kitty
```
Instalar Hyprland y dependencias
```bash
sudo pacman -S hyprland hyprpaper xwayland waybar foot rofi wofi \
    qt5-wayland qt6-wayland xdg-desktop-portal-hyprland \
    polkit-gnome network-manager-applet \
    pipewire wireplumber pavucontrol \
    thunar thunar-volman tumbler gvfs \
    noto-fonts ttf-dejavu ttf-font-awesome ttf-jetbrains-mono
```
Puedes usar paru o yay para instalar paquetes desde AUR si deseas personalizaciones adicionales como hyprlock, hypridle, etc.
## 🖼️ Configurar entorno gráfico
Crear la sesión en ~/.xinitrc o configurar el inicio automático con un login manager (ej: greetd o SDDM si usas Wayland-compatible).
```bash
[[ "$(tty)" = "/dev/tty1" ]] && exec Hyprland
```
## 💻 Integración con VMware
```bash
sudo pacman -S open-vm-tools xf86-video-vmware xf86-input-vmmouse
sudo systemctl enable vmtoolsd
```
Inicializar servicios
```bash
sudo systemctl enable vmtoolsd.service
sudo systemctl start vmtoolsd.service
```
---
### 🖥️ Login Manager (opcional)
```bash
sudo pacman -S greetd
sudo systemctl enable greetd
```
---
Hyprland funciona muy bien con greetd + tuigreet como interfaz.
---
### 📚 Repositorios Adicionales y Herramientas de Seguridad
AUR (Paru)
```bash
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin/
makepkg -si
```
BlackArch
```bash
mkdir ~/repositorio/blackarch
cd ~/repositorio/blackarch
curl -O https://blackarch.org/strap.sh
chmod +x strap.sh
sudo ./strap.sh
```
