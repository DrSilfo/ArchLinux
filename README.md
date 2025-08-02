
# 🐧 Guía de Instalación de Arch Linux con Hyprland en VMware (Intel)

## 🌐 Enlaces Útiles

- [Sitio Oficial de Arch Linux (ES)](https://www.archlinux-es.org/)
- [Descarga ISO Arch Linux](https://www.archlinux-es.org/descargar/)
- [Wiki Oficial Arch Linux](https://wiki.archlinux.org/)

---

## 🎯 Objetivo

Instalar **Arch Linux** desde cero en una máquina virtual **VMware**, con un entorno gráfico moderno basado en **Hyprland** (Wayland), un usuario no-root, y soporte completo para integración con VMware.

---

## 💻 Requisitos de la Máquina Virtual

- **Disco duro:** 100 GB
- **Memoria RAM:** 2 GB (mínimo), 4 GB recomendado
- **Procesadores:** 2 núcleos
- **Conectividad:** Preferentemente por cable (bridge o NAT)

---

## 🧩 1. Preinstalación

### ⌨️ Configurar teclado en español
```bash
loadkeys es
```

### 🌐 Verificar conexión a Internet
```bash
ping -c 3 archlinux.org
```

---

---

## 💽 3. Particionado del Disco

Verificar discos:
```bash
lsblk
```

**Distribución sugerida (100 GB):**

| Partición   | Punto de Montaje | Tamaño      | Tipo FS |
|-------------|------------------|-------------|---------|
| `/dev/sda1` | `/boot`          | 512 MB      | FAT32   |
| `/dev/sda2` | `swap`           | 8 GB        | swap    |
| `/dev/sda3` | `/`              | 30 GB       | ext4    |
| `/dev/sda4` | `/home`          | ~61.5 GB    | ext4    |

Crear particiones con:
```bash
cgdisk /dev/sda
```

- `sda1` → Tipo: `EF00` (EFI System)
- `sda2` → Tipo: `8200` (Linux Swap)
- `sda3` y `sda4` → Tipo: `8300` (Linux Filesystem)

### 🧹 Formatear y activar particiones
```bash
mkfs.fat -F32 /dev/sda1
mkswap /dev/sda2
swapon /dev/sda2
mkfs.ext4 /dev/sda3
mkfs.ext4 /dev/sda4
```

---

## 📂 4. Montaje de Particiones

```bash
mount /dev/sda3 /mnt
mkdir -p /mnt/boot /mnt/home
mount /dev/sda1 /mnt/boot
mount /dev/sda4 /mnt/home
```

---

## 📥 5. Instalación del Sistema Base

```bash
pacstrap /mnt base base-devel linux linux-firmware linux-headers grub vim
```

Generar `fstab`:
```bash
genfstab -U /mnt > /mnt/etc/fstab
```

---

## 🧳 6. Chroot al sistema instalado

```bash
arch-chroot /mnt
```

---

## ⚙️ 7. Configuración del Sistema

### Configuración de localización y zona horaria

```bash
echo "es_ES.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
export LANG=es_ES.UTF-8
timedatectl set-ntp true
```

### GRUB (para BIOS/UEFI)
```bash
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
```

Opcional:
```bash
vim /etc/default/grub
# Puedes ajustar GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3"
```


---

## ⚙️ 7. Configuración del Sistema

### GRUB (para BIOS/UEFI)
```bash
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
```

Opcional:
```bash
vim /etc/default/grub
# Puedes ajustar GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3"
```

### Configuración de red y servicios
```bash
pacman -S dhcpcd iwd networkmanager net-tools ifplugd reflector \
  xdg-utils xdg-user-dirs
```

Habilitar servicios:
```bash
systemctl enable NetworkManager
systemctl enable iwd
```

### Paquetes básicos
```bash
pacman -S git wget curl openssh neofetch htop unzip p7zip lsb-release
```

### Zona horaria y reloj
```bash
ln -sf /usr/share/zoneinfo/America/Lima /etc/localtime
timedatectl set-timezone America/Lima
hwclock --systohc
```

### Localización
```bash
vim /etc/locale.gen
# Descomenta: es_PE.UTF-8
locale-gen
echo LANG=es_PE.UTF-8 > /etc/locale.conf
echo KEYMAP=es > /etc/vconsole.conf
```

### Configuración opcional de `pacman`
```bash
vim /etc/pacman.conf
# Activar:
# Color
# CheckSpace
# VerbosePkgLists
# ParallelDownloads = 5
# ILoveCandy
```

---

## 🌐 8. Hostname y red

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

## 🔐 9. Contraseña y usuario

Contraseña root:
```bash
passwd
```

Crear usuario:
```bash
useradd -mG wheel drsilfo
passwd drsilfo
EDITOR=vim visudo
# Descomenta: %wheel ALL=(ALL:ALL) ALL
```

---

## 🔄 10. Actualizar mirrorlist

```bash
reflector --verbose --latest 10 --protocol https --sort rate --save /etc/pacman.d/mirrorlist
```

---

## 🔁 11. Salir y reiniciar

```bash
exit
umount -R /mnt
reboot
```

---

# 🧑‍💻 Preparación del Entorno Gráfico

Una vez hayas iniciado sesión como el usuario no-root (ej. `drsilfo`), instala un emulador de terminal funcional antes de lanzar Hyprland:

```bash
sudo pacman -S git kitty
```

Crea la configuración de Hyprland e indica que se ejecute `kitty` al inicio de la sesión gráfica:

```bash
mkdir -p ~/.config/hypr
echo "exec-once = kitty" > ~/.config/hypr/hyprland.conf
```

---

## 💠 Instalar Hyprland y dependencias

```bash
sudo pacman -S hyprland hyprpaper xwayland waybar foot rofi wofi \
  qt5-wayland qt6-wayland xdg-desktop-portal-hyprland \
  polkit-gnome network-manager-applet \
  pipewire wireplumber pavucontrol \
  thunar thunar-volman tumbler gvfs \
  noto-fonts ttf-dejavu ttf-font-awesome ttf-jetbrains-mono
```

> Recomendado: instalar `paru` o `yay` para acceso a AUR:
```bash
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin
makepkg -si
```

---

## 🖼️ Configuración de entorno gráfico

Inicia Hyprland automáticamente en tty1:
```bash
[[ "$(tty)" = "/dev/tty1" ]] && exec Hyprland
```

---

## 🖥️ Integración con VMware

```bash
sudo pacman -S open-vm-tools xf86-video-vmware xf86-input-vmmouse
sudo systemctl enable --now vmtoolsd.service
```

---

## 🔐 Login Manager (opcional)

Recomendado: greetd + tuigreet
```bash
sudo pacman -S greetd
sudo systemctl enable greetd
```

---

## 🛡️ Repositorios adicionales (opcional)

### AUR (Paru)
```bash
git clone https://aur.archlinux.org/paru-bin.git
cd paru-bin
makepkg -si
```

### BlackArch (opcional, uso avanzado)
```bash
mkdir -p ~/repositorio/blackarch
cd ~/repositorio/blackarch
curl -O https://blackarch.org/strap.sh
chmod +x strap.sh
sudo ./strap.sh
```

---

## ✅ Conclusión

Con estos pasos tienes un sistema Arch Linux **ligero, moderno y personalizado**, con **Hyprland** corriendo sobre **Wayland**, totalmente funcional en **VMware** con soporte para red, gráficos, sonido y herramientas esenciales.
