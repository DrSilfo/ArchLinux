# 🐧 Guía de Instalación de Arch Linux con Hyprland en VMware (Intel)

---

## 🌐 Enlaces Útiles

- [Sitio Oficial de Arch Linux (ES)](https://www.archlinux-es.org/)
- [Descarga ISO Arch Linux](https://www.archlinux-es.org/descargar/)
- [Wiki Oficial Arch Linux](https://wiki.archlinux.org/)
- [Guía Oficial Hyprland - Tutorial Maestro](https://wiki.hypr.land/Getting-Started/Master-Tutorial/)
- [Instalación Oficial de Hyprland](https://wiki.hypr.land/Getting-Started/Installation/)
- [Ecosistema Hypr](https://wiki.hypr.land/Hypr-Ecosystem/)

---

## 🎯 Objetivo

Instalar **Arch Linux** desde cero en una máquina virtual **VMware**, configurando un entorno gráfico moderno basado en **Hyprland** sobre **Wayland**, con:

- Un usuario no-root funcional.
- Integración completa con VMware Tools.
- Aplicaciones básicas como el emulador de terminal **Kitty**.
- Base para un entorno estético, funcional y altamente personalizable.

---

## 💻 Requisitos de la Máquina Virtual

- **Disco duro:** 100 GB
- **Memoria RAM:** 4 GB (2 GB mínimo)
- **Procesadores:** 2 núcleos
- **Red:** Bridge o NAT (preferentemente cableada)

---

## 🧬 1. Preinstalación

### ⌨️ Configurar teclado en español

```bash
loadkeys es
```

### 🌐 Verificar conexión a Internet

```bash
ping -c 3 archlinux.org
```

---

## 📀 2. Particionado del Disco

### Verificar discos disponibles:

```bash
lsblk
```

### Esquema sugerido (100 GB):

| Partición   | Punto de Montaje | Tamaño  | Tipo FS | Tipo Partición |
| ----------- | ---------------- | ------- | ------- | -------------- |
| `/dev/sda1` | `/boot`          | 512 MB  | ext4    | Linux          |
| `/dev/sda2` | `swap`           | 8 GB    | swap    | Linux swap     |
| `/dev/sda3` | `/`              | \~91 GB | ext4    | Linux          |

### Borrar tabla de particiones y crear nueva:

```bash
wipefs -a /dev/sda
cfdisk /dev/sda
```

Seleccionar "dos" (MBR).

### Formatear y activar particiones:

```bash
mkfs.ext4 /dev/sda1
mkswap /dev/sda2
swapon /dev/sda2
mkfs.ext4 /dev/sda3
```

---

## 📂 3. Montaje de Particiones

```bash
mount /dev/sda3 /mnt
mkdir /mnt/boot
mount /dev/sda1 /mnt/boot
```

---

## 📥 4. Instalación del Sistema Base

```bash
pacstrap /mnt base base-devel linux linux-firmware linux-headers grub vim
```

### Generar `fstab`:

```bash
genfstab -U /mnt > /mnt/etc/fstab
```

---

## 🛫 5. Chroot al Sistema Instalado

```bash
arch-chroot /mnt
```

---

## ⚙️ 6. Configuración del Sistema

### Localización y zona horaria:

```bash
echo "es_PE.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
export LANG=es_PE.UTF-8
echo LANG=es_PE.UTF-8 > /etc/locale.conf
echo KEYMAP=es > /etc/vconsole.conf
ln -sf /usr/share/zoneinfo/America/Lima /etc/localtime
hwclock --systohc
timedatectl set-ntp true
```

### Configuración de GRUB (BIOS/MBR):

```bash
grub-install --target=i386-pc /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
```

---

## 🔧 7. Red, Servicios y Paquetes Básicos

### Servicios de red:

```bash
pacman -S networkmanager reflector net-tools xdg-utils xdg-user-dirs
systemctl enable NetworkManager
```

### Utilidades esenciales:

```bash
pacman -S git wget curl openssh unzip p7zip lsb-release file kitty eog xarchiver
```

### Optimizar `pacman.conf` (opcional):

```bash
vim /etc/pacman.conf
```

Activa:

- Color
- CheckSpace
- VerbosePkgLists
- ParallelDownloads = 5
- ILoveCandy

---

## 🌐 8. Hostname y Red

```bash
echo archcat > /etc/hostname
```

Editar `/etc/hosts`:

```bash
127.0.0.1   localhost
::1         localhost
127.0.1.1   archcat.localdomain archcat
```

---

## 🔐 9. Contraseña y Usuario

```bash
passwd
useradd -mG wheel drsilfo
passwd drsilfo
EDITOR=vim visudo
```

Descomenta la línea:

```bash
%wheel ALL=(ALL:ALL) ALL
```

---

## 🔄 10. Mirrorlist Actualizado

```bash
reflector --verbose --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

---

## ↺ 11. Finalizar Instalación

```bash
exit
umount -R /mnt
reboot
```

---

## 🖥️ 12. Integración con VMware (ya dentro del sistema)

```bash
paru -S open-vm-tools xf86-video-vmware xf86-input-vmmouse
sudo systemctl enable --now vmtoolsd.service
```

---

## 🛀 13. Instalación de Hyprland y Dependencias

Basado en [la guía oficial de Hyprland](https://wiki.hypr.land/Getting-Started/Installation/):

```bash
sudo pacman -S hyprland hyprpaper xorg-xwayland waybar wofi \
  qt5-wayland qt6-wayland xdg-desktop-portal-hyprland \
  polkit-gnome network-manager-applet pipewire wireplumber \
  pavucontrol thunar thunar-volman tumbler gvfs \
  noto-fonts ttf-dejavu ttf-font-awesome ttf-jetbrains-mono
```

---

## 🧑‍💻 14. Configuración del Entorno Hyprland

Inicia sesión como tu usuario no-root:

```bash
mkdir -p ~/.config/hypr
cp /etc/xdg/hypr/hyprland.conf ~/.config/hypr/hyprland.conf
```

Agrega la línea:

```conf
exec-once = kitty
```

También puedes explorar ejemplos desde [Hyprland Master Tutorial](https://wiki.hypr.land/Getting-Started/Master-Tutorial/)

---

## 🔐 15. Login Manager (Opcional)

### greetd + tuigreet

```bash
sudo pacman -S greetd
yay -S greetd-tuigreet
```

Habilita el servicio:

```bash
sudo systemctl enable greetd
```

Edita `/etc/greetd/config.toml`:

```toml
[terminal]
vt = 1

[default_session]
command = "tuigreet --cmd Hyprland"
user = "drsilfo"
```

Reinicia:

```bash
reboot
```

---

## 🛡️ 16. Repositorios Adicionales (Opcionales)

### AUR con `paru`

```bash
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin
makepkg -si
```

### `yay` (alternativa):

```bash
sudo pacman -S --needed base-devel git
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

### BlackArch (avanzado):

```bash
mkdir -p ~/repositorio/blackarch
cd ~/repositorio/blackarch
curl -O https://blackarch.org/strap.sh
chmod +x strap.sh
sudo ./strap.sh
```

---

## ✅ Conclusión

Ahora tienes un sistema **Arch Linux** minimalista, moderno y funcional sobre **Wayland** con **Hyprland**, optimizado para **VMware**, con soporte para red, sonido, fuentes y una terminal estéticamente potente (Kitty).

Explora el [ecosistema Hyprland](https://wiki.hypr.land/Hypr-Ecosystem/) para seguir personalizando tu entorno gráfico con notificaciones, portales, widgets, y más.

