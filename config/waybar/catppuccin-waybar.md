**Catppuccin** is a **community-driven pastel theme** that originated as a color palette for code editors (VS Code, Vim, etc.) and has since expanded into a **full ecosystem of themes** for terminals, shells, desktop environments, and applications — including **Waybar**.

It’s known for its:

- **Soft, pastel colors** (easy on the eyes)
- **Four official “flavors”** (color variants)
- **Consistent design** across 100+ apps
- **Highly customizable** via simple variables

---

## 1. The 4 Flavors (Color Variants)

| Flavor     | Accent Color | Vibe |
|-----------|--------------|------|
| **Latte**   | Blue         | Light theme (day) |
| **Frappé**  | Teal         | Light-mid |
| **Macchiato**| Pink       | Dark-mid |
| **Mocha**   | Lavender     | Dark (night) **← most popular** |

> Each flavor shares the **same structure** but uses different base colors.

---

## 2. Core Color Palette (Mocha example)

```css
/* Catppuccin Mocha */
@define-color rosewater #f5e0dc;
@define-color flamingo  #f2cdcd;
@define-color pink      #f5c2e7;
@define-color mauve     #cba6f7;
@define-color red       #f38ba8;
@define-color maroon    #eba0ac;
@define-color peach     #fab387;
@define-color yellow    #f9e2af;
@define-color green     #a6e3a1;
@define-color teal      #94e2d5;
@define-color sky       #89dceb;
@define-color sapphire  #74c7ec;
@define-color blue      #89b4fa;
@define-color lavender  #b4befe;
@define-color text      #cdd6f4;
@define-color subtext1  #bac2de;
@define-color subtext0  #a6adc8;
@define-color overlay2  #9399b2;
@define-color overlay1  #7f849c;
@define-color overlay0  #6c7086;
@define-color surface2  #585b70;
@define-color surface1  #45475a;
@define-color surface0  #313244;
@define-color base      #1e1e2e;
@define-color mantle    #181825;
@define-color crust     #11111b;
```

> All flavors follow this **naming convention** — only the hex values change.

---

## 3. Waybar + Catppuccin

Your `catppuccin-waybar.css` is likely a **premade stylesheet** using these variables.

### Example: `style.css` using Catppuccin

```css
/* ~/.config/waybar/styles/mocha/style.css */
@import "catppuccin-waybar.css";

* {
    font-family: JetBrainsMono Nerd Font;
    font-size: 13px;
    color: @text;
}

window#waybar {
    background: alpha(@base, 0.9);
    border-bottom: 2px solid @mauve;
}

#workspaces button {
    padding: 0 8px;
    color: @subtext0;
}

#workspaces button.focused {
    background: @mauve;
    color: @base;
    border-radius: 6px;
}

#clock, #battery, #cpu, #memory, #network, #pulseaudio {
    padding: 0 12px;
    margin: 0 4px;
    background: @surface0;
    border-radius: 8px;
}
```

> You `@import` the base palette → override only what you need.

---

## 4. How to Use Catppuccin in Your Setup

### Step 1: Get the palette

```bash
# Option A: Clone official repo
git clone https://github.com/catppuccin/waybar ~/.config/waybar/catppuccin

# Option B: Use your existing file
# You already have: catppuccin-waybar.css
```

### Step 2: Create flavor-specific styles

```
~/.config/waybar/styles/
├── mocha/
│   ├── config
│   └── style.css
├── latte/
│   ├── config
│   └── style.css
└── shared/
    └── catppuccin-waybar.css   ← shared palette
```

### `shared/catppuccin-waybar.css` (Mocha)

```css
/* Catppuccin Mocha */
@define-color base      #1e1e2e;
@define-color mantle    #181825;
@define-color crust     #11111b;
@define-color text      #cdd6f4;
@define-color mauve     #cba6f7;
@define-color pink      #f5c2e7;
@define-color red       #f38ba8;
@define-color peach     #fab387;
@define-color green     #a6e3a1;
@define-color blue      #89b4fa;
/* ... rest ... */
```

### `styles/mocha/style.css`

```css
@import "../../catppuccin-waybar.css";

/* Your custom Waybar styling */
window#waybar {
    background: alpha(@base, 0.95);
    border-bottom: 3px solid @mauve;
}
```

> Now all your styles inherit the **same palette** → easy to switch flavors.

---

## 5. Switch Flavors with Your Script

Update your `switch-waybar-style.sh` to support **flavors inside a theme**:

```bash
# Example: switch to Catppuccin Mocha
./switch-waybar-style.sh catppuccin-mocha

# Directory structure:
# styles/catppuccin-mocha/config
# styles/catppuccin-mocha/style.css
```

Or make a **meta-style** that picks flavor:

```bash
# styles/catppuccin/
#   ├── mocha.css → symlinks to ../../shared/catppuccin-mocha.css
#   ├── latte.css → ...
#   └── style.css → imports current flavor
```

---

## 6. Bonus: Auto Dark/Light Switching

```bash
# ~/.config/waybar/scripts/auto-catppuccin.sh
#!/usr/bin/env bash
HOUR=$(date '+%H')
if (( HOUR >= 7 && HOUR < 19 )); then
    ~/.config/waybar/switch-waybar-style.sh catppuccin-latte
else
    ~/.config/waybar/switch-waybar-style.sh catppuccin-mocha
fi
```

Run via `systemd` timer or `cron`.

---

## Official Resources

| Link | Purpose |
|------|--------|
| [catppuccin.com](https://catppuccin.com) | Palette generator, ports |
| [GitHub: catppuccin/waybar](https://github.com/catppuccin/waybar) | Official Waybar theme |
| [Palette Generator](https://catppuccin.com/palette) | Build custom flavors |

---

## TL;DR: How to Use in Your Dotfiles

1. Keep `catppuccin-waybar.css` in a shared place
2. Create `styles/catppuccin-mocha/`, `latte/`, etc.
3. Each has:
   - `config` (Waybar JSONC)
   - `style.css` → `@import "../../catppuccin-mocha.css";`
4. Use your `switch-waybar-style.sh` to pick one
5. Enjoy consistent, beautiful, pastel Waybar

---

**Your current `catppuccin-waybar.css`** is probably **Mocha**. Try creating `latte` version and switch at sunrise!
