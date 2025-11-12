Here's how to add the missing Oh My Zsh plugins to your Dotbot configuration:

**Update your `install.conf.yaml`:**

```yaml
- clean: ['~']

- shell:
    - command: chsh -s $(which zsh)
      description: Setting zsh as default shell
      stdin: true

- link:
    ~/.aliases: aliases
    ~/.gitconfig: gitconfig
    ~/.tmux.conf: tmux.conf
    ~/.pythonrc: pythonrc

- create:
    - ~/notes
    - ~/.local/bin
    - ~/go/bin

- shell:
    - [git submodule update --init --recursive, Installing submodules]
    - [./install_plugins, Installing Oh My Zsh plugins]

- shell:
    - command: |
        if [ ! -d ~/.oh-my-zsh ]; then
          sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        fi
      description: Installing Oh My Zsh

- shell:
    - command: |
        if command -v pip3 &> /dev/null; then
          pip3 install --user uv
        fi
      description: Installing uv

- shell:
    - [command -v cargo && cargo install bat exa fd-find duf procs || echo "Cargo not available", Installing Rust tools]
```

**Create an `install_plugins` script:**

Create a file called `install_plugins` in your dotfiles repository:

```bash
#!/bin/bash

set -e

# Oh My Zsh custom plugins directory
ZSH_CUSTOM="${ZSH_CUSTOM:-${HOME}/.oh-my-zsh/custom}"

# List of plugins to install
plugins=(
    "zsh-users/zsh-completions"
    "Aloxaf/fzf-tab"
    "MichaelAquilina/zsh-you-should-use"
    "GoodClover/fabric-plugin"
)

echo "Installing Oh My Zsh plugins..."

for plugin in "${plugins[@]}"; do
    plugin_name=$(basename "$plugin")
    plugin_dir="$ZSH_CUSTOM/plugins/$plugin_name"
    
    if [ ! -d "$plugin_dir" ]; then
        echo "Installing $plugin_name..."
        git clone -q "https://github.com/$plugin" "$plugin_dir"
    else
        echo "Updating $plugin_name..."
        git -C "$plugin_dir" pull -q
    fi
done

# Install zsh-syntax-highlighting if not present
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "Installing zsh-syntax-highlighting..."
    git clone -q https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
fi

# Install zsh-autosuggestions if not present
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "Installing zsh-autosuggestions..."
    git clone -q https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
fi

echo "Oh My Zsh plugins installation complete!"
```

Make it executable:
```bash
chmod +x install_plugins
```

**Alternative: Add plugin installation directly to your Dotbot config:**

If you prefer to keep everything in the YAML file, you can modify your `install.conf.yaml` like this:

```yaml
- clean: ['~']

- shell:
    - command: chsh -s $(which zsh)
      description: Setting zsh as default shell
      stdin: true

- link:
    ~/.aliases: aliases
    ~/.gitconfig: gitconfig
    ~/.tmux.conf: tmux.conf
    ~/.pythonrc: pythonrc
    ~/.zshrc: zshrc

- create:
    - ~/notes
    - ~/.local/bin
    - ~/go/bin

- shell:
    - [git submodule update --init --recursive, Installing submodules]

- shell:
    - command: |
        if [ ! -d ~/.oh-my-zsh ]; then
          sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        fi
      description: Installing Oh My Zsh

- shell:
    - command: |
        ZSH_CUSTOM="${HOME}/.oh-my-zsh/custom"
        
        # Install missing plugins
        plugins=(
            "zsh-users/zsh-completions"
            "Aloxaf/fzf-tab" 
            "MichaelAquilina/zsh-you-should-use"
            "GoodClover/fabric-plugin"
        )
        
        for plugin in "${plugins[@]}"; do
            plugin_name=$(basename "$plugin")
            plugin_dir="$ZSH_CUSTOM/plugins/$plugin_name"
            if [ ! -d "$plugin_dir" ]; then
                echo "Installing $plugin_name..."
                git clone -q "https://github.com/$plugin" "$plugin_dir"
            fi
        done
        
        # Install syntax highlighting and autosuggestions if missing
        [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] && \
          git clone -q https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
        
        [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] && \
          git clone -q https://github.com/zsh-users/zsh-autosuggestions.git "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
      description: Installing Oh My Zsh plugins

- shell:
    - command: |
        if command -v pip3 &> /dev/null; then
          pip3 install --user uv
        elif command -v pip &> /dev/null; then
          pip install --user uv
        fi
      description: Installing uv

- shell:
    - command: |
        if command -v cargo &> /dev/null; then
          cargo install bat exa fd-find duf procs --locked
        else
          echo "Cargo not available, skipping Rust tools installation"
        fi
      description: Installing Rust tools

- shell:
    - command: |
        if command -v brew &> /dev/null; then
          brew install fzf bat fd exa duf procs
        elif command -v apt &> /dev/null; then
          sudo apt update && sudo apt install -y fzf bat fd-find exa duf procs
        elif command -v dnf &> /dev/null; then
          sudo dnf install -y fzf bat fd-find exa duf procs
        fi
      description: Installing system packages
```

**Update your `.zshrc` with the complete plugin list:**

Make sure your `.zshrc` includes all the plugins:

```zsh
plugins=(
  git sudo supervisor docker docker-compose
  python npm node uv fabric rust
  zsh-autosuggestions zsh-syntax-highlighting zsh-completions
  colored-man-pages copyfile copypath dirhistory web-search jsontools
  fzf-tab you-should-use
)
```

**Run the installation:**

```bash
./install
```

This setup will:
1. Install Oh My Zsh if not present
2. Clone all the required plugins to the correct directories
3. Install necessary tools like `uv` and modern CLI utilities
4. Handle both Rust-based and system package manager installations

The Dotbot configuration ensures everything is installed automatically when you set up a new system or update your existing setup.
