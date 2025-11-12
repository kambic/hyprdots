Perfect — Arch Linux is the **best distro** for Hyprland and Nouveau setups, since everything is bleeding-edge and easy to configure.

Let’s go step-by-step for your **ThinkPad W550s (Intel + NVIDIA K620M)**.

---

## 🧩 1. Base Setup

First, make sure your system is up-to-date:

```bash
sudo pacman -Syu
```

Then install the **base graphics stack** and tools:

```bash
sudo pacman -S mesa vulkan-intel vulkan-nouveau libva-mesa-driver mesa-utils xf86-video-nouveau
```

That ensures both Intel and Nouveau (NVIDIA) Mesa drivers are installed.

---

## 🧹 2. Remove Any Proprietary NVIDIA Stuff

If you ever installed NVIDIA’s driver, remove it completely:

```bash
sudo pacman -Rns nvidia nvidia-utils nvidia-settings nvidia-dkms
```

Then rebuild your initramfs:

```bash
sudo mkinitcpio -P
```

---

## ⚙️ 3. Enable Nouveau (and Blacklist NVIDIA)

Create:

```bash
sudo nano /etc/modprobe.d/nouveau.conf
```

Add:

```conf
blacklist nvidia
blacklist nvidia_drm
blacklist nvidia_modeset
```

Load Nouveau automatically:

```bash
echo "nouveau" | sudo tee /etc/modules-load.d/nouveau.conf
```

Reboot once to make sure it’s active.

After reboot, verify:

```bash
lsmod | grep nouveau
```

---

## 💻 4. Intel as Primary GPU

On Optimus systems, you want the **Intel GPU** to drive displays and **Nouveau** to handle offloading if needed.

Install `xorg-xrandr` and `xorg-xset` (useful for debugging):

```bash
sudo pacman -S xorg-xrandr xorg-xset
```

Optional X11 device ordering (can still help Wayland sorting):

Create `/etc/X11/xorg.conf.d/10-gpu.conf`:

```conf
Section "Device"
    Identifier "Intel Graphics"
    Driver "modesetting"
    BusID "PCI:0:2:0"
EndSection

Section "Device"
    Identifier "NVIDIA"
    Driver "nouveau"
    BusID "PCI:1:0:0"
    Option "AccelMethod" "glamor"
EndSection
```

---

## 🌈 5. Install Hyprland and Friends

Install Hyprland and recommended packages:

```bash
sudo pacman -S hyprland waybar wofi xdg-desktop-portal-hyprland
```

Optional utilities:

```bash
sudo pacman -S nwg-look qt5-wayland qt6-wayland brightnessctl pavucontrol
```

---

## 🧠 6. Configure Hyprland for Nouveau

Create/edit your Hyprland config:

```bash
mkdir -p ~/.config/hypr
nano ~/.config/hypr/hyprland.conf
```

Add this minimal setup:

```ini
monitor=,preferred,auto,1

# Use Intel as main renderer
env = WLR_DRM_DEVICES,/dev/dri/card0

# Wayland env tweaks for Nouveau
env = WLR_NO_HARDWARE_CURSORS,1
env = LIBVA_DRIVER_NAME,nouveau
env = GBM_BACKEND,nouveau
env = __GLX_VENDOR_LIBRARY_NAME,mesa
env = MESA_LOADER_DRIVER_OVERRIDE,nouveau

# Hyprland behavior
render_backend=auto
exec-once = waybar &
exec-once = wofi --show drun
```

You can test which `/dev/dri/cardX` is which by running:

```bash
sudo lshw -C display
```

Intel should be `/dev/dri/card0`, Nouveau `/dev/dri/card1`.

---

## 🚀 7. Start Hyprland

From a TTY (no display manager):

```bash
Hyprland
```

If you get a black screen or crash, try:

```bash
WLR_RENDERER_ALLOW_SOFTWARE=1 Hyprland
```

That forces software rendering (good for debugging Nouveau issues).

---

## 🔍 8. Verify Nouveau Rendering

Check which GPU Mesa is using:

```bash
glxinfo | grep "OpenGL renderer"
```

Expected:

```
OpenGL renderer string: NV117 (nouveau, NV117)
```

Or for Intel:

```
OpenGL renderer string: Mesa Intel(R) HD Graphics ...
```

You can also check Vulkan:

```bash
vulkaninfo | grep deviceName
```

---

## ⚡ 9. Power Management (Recommended)

Enable runtime power management for the NVIDIA chip when idle:

```bash
sudo tee /etc/modprobe.d/nouveau-power.conf <<EOF
options nouveau runpm=1
EOF
```

Then reboot.

---

## 🧩 Optional: Mesa-Nouveau-Git (Performance Boost)

Arch’s stable Nouveau can be slow. You can try the latest Mesa driver for better support:

```bash
yay -S mesa-git lib32-mesa-git
```

Then reboot again.

---

## ✅ Summary

| Component      | Package/Config                                     |
| -------------- | -------------------------------------------------- |
| Nouveau driver | `xf86-video-nouveau` + Mesa                        |
| Intel driver   | `modesetting` (built-in)                           |
| Compositor     | `hyprland`                                         |
| Key env vars   | `WLR_NO_HARDWARE_CURSORS=1`, `GBM_BACKEND=nouveau` |
| Power mgmt     | `options nouveau runpm=1`                          |

---

Would you like me to include an **optional section for NVIDIA offloading** (so you can run specific apps on the NVIDIA GPU under Nouveau, e.g., `DRI_PRIME=1 glxinfo`)?
