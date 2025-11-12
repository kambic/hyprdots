
### ✅ Regular update routine

```bash
yay -Syu --devel --timeupdate
```

* `--devel`: updates `-git`, `-svn`, etc. packages
* `--timeupdate`: only rebuilds AUR packages with newer versions


## 🧰 3. Managing AUR Packages

### View and remove unused AUR packages

```bash
yay -Yc     # clean unneeded dependencies
yay -Ps     # show package statistics (explicit vs deps)
```

### Remove orphans

```bash
sudo pacman -Rns $(pacman -Qtdq)
```

### Rebuild broken or outdated AUR packages

If you see build errors:

```bash
yay -S pkgname --rebuildtree
```

Or rebuild all AURs (if many have broken deps):

```bash
yay -S --rebuildall --aur
```

---

## 🧹 4. Cleaning Build Cache

Yay stores build files in `~/.cache/yay`.
To keep space free:

```bash
yay -Sc      # clean all build caches
```

or automatically clean old versions:

```bash
yay -Scc
```


## 🧩 5. Handling Orphans & Out-of-Date AUR Packages

```bash
yay -Ps | grep Orphan
```

### Check flagged-out-of-date packages:

```bash
yay -Ps | grep "Out Of Date"
```
---

## 🧑‍💻 7. Check Build Scripts for Safety

Never blindly install from the AUR. Before building:

```bash
yay -G pkgname
cd pkgname
less PKGBUILD
```

Check for:

* `curl | bash` or `sudo` calls
* Strange sources or post-install scripts

---

## 💾 8. Backup Before Major Updates

Before kernel or system upgrades:

```bash
sudo timeshift --create --comments "Pre-update snapshot"
```

or at least:

```bash
sudo cp /boot/vmlinuz-linux /boot/vmlinuz-linux.bak
```

and backup `/etc` configs.

---

## 🩹 9. Recover from Broken AUR Packages

If a build fails mid-update:

1. Skip it:

   ```bash
   yay -Syu --ignore pkgname
   ```
2. Rebuild later or downgrade:

   ```bash
   yay -U /var/cache/pacman/pkg/pkgname-oldver.pkg.tar.zst
   ```

---

## 🧭 10. Keep a Lightweight AUR Setup

Avoid installing *too many* AUR packages — they require manual oversight.
Stick to well-maintained, high-vote packages when possible.

Check how many AUR packages you have:

```bash
pacman -Qm
```


```bash
alias aurcheck='yay -Ps | grep -E "Orphan|Out Of Date"'
```
