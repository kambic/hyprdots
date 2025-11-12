#
# HISTFILE=~/.histfile
# HISTSIZE=5000
# SAVEHIST=5000
# # Oh-my-zsh installation path
# ZSH=~/.oh-my-zsh
# # List of plugins used
# plugins=(
#   docker
#   docker-compose
#   fabric
#   uv
#   sudo
#   supervisor
#   starship
#   zsh-autosuggestions
#   zsh-syntax-highlighting
# )
# source $ZSH/oh-my-zsh.sh
# source ~/.aliases
# source <(fzf --zsh)
# ===== Zsh Configuration =====
# History settings
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt EXTENDED_HISTORY       # Record timestamp and duration
setopt HIST_EXPIRE_DUPS_FIRST # Expire duplicate first
setopt HIST_IGNORE_DUPS       # Ignore consecutive duplicates
setopt HIST_IGNORE_ALL_DUPS   # Remove older duplicate entries
setopt HIST_FIND_NO_DUPS      # Ignore duplicates when searching
setopt HIST_IGNORE_SPACE      # Ignore commands starting with space
setopt HIST_SAVE_NO_DUPS      # Don't save duplicates
setopt HIST_REDUCE_BLANKS     # Remove superfluous blanks
setopt SHARE_HISTORY          # Share history between sessions
setopt INC_APPEND_HISTORY     # Append to history immediately

# ===== Oh My Zsh Configuration =====
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="" # Disable OMZ themes since we're using Starship

# Safe plugin list - only include plugins that are definitely installed
plugins=(
  # Core utilities
  git
  sudo
  supervisor
  docker
  docker-compose

  # Development tools
  python
  npm
  node

  # Modern enhancements
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  fzf-tab
  you-should-use
  colored-man-pages
  copyfile
  copypath
  dirhistory
  web-search
)

# Optional plugins - uncomment after installing
# plugins+=(fabric uv rust jsontools)

# ===== Plugin Configuration =====
# Zsh Autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"

# Zsh Syntax Highlighting - Safe configuration
if [ -d "${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ] || [ -d "/usr/share/zsh/plugins/zsh-syntax-highlighting" ]; then
  typeset -A ZSH_HIGHLIGHT_STYLES
  ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
  ZSH_HIGHLIGHT_STYLES[command]='fg=green'
  ZSH_HIGHLIGHT_STYLES[alias]='fg=cyan'
  ZSH_HIGHLIGHT_STYLES[builtin]='fg=yellow'
  ZSH_HIGHLIGHT_STYLES[function]='fg=cyan'
  ZSH_HIGHLIGHT_STYLES[path]='underline'
  ZSH_HIGHLIGHT_STYLES[single - hyphen - option]='fg=blue'
  ZSH_HIGHLIGHT_STYLES[double - hyphen - option]='fg=blue'
fi

# FZF configuration
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
if command -v bat &>/dev/null; then
  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --preview 'bat --color=always {} 2>/dev/null || cat {}'"
else
  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --preview 'cat {}'"
fi

if command -v fd &>/dev/null; then
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
else
  export FZF_DEFAULT_COMMAND='find . -type f -not -path "*/\.git/*"'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_ALT_C_COMMAND="find . -type d -not -path "*/\.git/*""
fi

# ===== Load Oh My Zsh =====
source $ZSH/oh-my-zsh.sh

# ===== Custom Functions =====
# Quick directory navigation with fzf
function fz() {
  local dir
  if command -v fd &>/dev/null; then
    dir=$(fd --type d --hidden --follow --exclude .git 2>/dev/null | fzf --height 40% --reverse)
  else
    dir=$(find . -type d -not -path "*/\.git/*" 2>/dev/null | fzf --height 40% --reverse)
  fi
  [ -n "$dir" ] && cd "$dir"
}

# Enhanced git log with fzf
function glf() {
  if ! git rev-parse --is-inside-work-tree &>/dev/null; then
    echo "Not a git repository"
    return 1
  fi

  local commit_hash=$(git log --color=always --format="%C(auto)%h %s %C(blue)%cr" | fzf --ansi --no-sort --reverse | grep -o '^[a-f0-9]*')
  [ -n "$commit_hash" ] && git show "$commit_hash"
}

# Create and cd into directory
function mkcd() {
  mkdir -p "$1" && cd "$1"
}

# Quick note-taking
function note() {
  local note_dir="${NOTE_DIR:-$HOME/notes}"
  mkdir -p "$note_dir"
  local filename="$note_dir/$(date +%Y-%m-%d).md"
  ${EDITOR:-vim} "$filename"
}

# Weather information
function weather() {
  curl -s "wttr.in/${1:-Brussels}?1"
}

# ===== Aliases =====
# Source custom aliases if exists
[ -f ~/.aliases ] && source ~/.aliases

# Modern replacements for common commands
if command -v exa &>/dev/null; then
  alias ls='exa --icons'
  alias ll='exa -alF --icons'
  alias la='exa -A --icons'
  alias lt='exa -T --icons'
else
  alias ls='ls --color=auto'
  alias ll='ls -alF'
  alias la='ls -A'
  alias lt='tree'
fi

if command -v bat &>/dev/null; then
  alias cat='bat'
fi

# Enhanced git aliases
alias gs='git status'
alias gd='git diff'
alias gdc='git diff --cached'
alias gl='git log --oneline --graph --decorate'
alias gaa='git add .'
alias gc='git commit'
alias gcm='git commit -m'
alias gp='git push'
alias gpl='git pull'

# Docker aliases
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias drm='docker rm'
alias drmi='docker rmi'

# Python development
alias py='python'
alias pip='uv pip 2>/dev/null || pip' # Use uv for pip if available
alias venv='python -m venv .venv && source .venv/bin/activate'

# ===== Environment Variables =====
export EDITOR='nvim' # or 'vim', 'code', etc.
export VISUAL="$EDITOR"
export PAGER='less'
export BROWSER='firefox'

# Python development
export PYTHONSTARTUP="$HOME/.pythonrc"
export PIP_REQUIRE_VIRTUALENV=false

# Node.js
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" 2>/dev/null

# Rust
[ -f "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# Go
export PATH="$HOME/go/bin:$PATH"

# Local bin directory
export PATH="$HOME/.local/bin:$PATH"

# ===== Completions =====
autoload -Uz compinit
compinit

# ===== FZF Integration =====
# Only source if fzf is installed
if command -v fzf &>/dev/null; then
  [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
fi

# ===== Starship Prompt =====
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi

# ===== Startup Messages =====
# Simple startup message without timestamp calculation
echo "🚀 Zsh loaded successfully"

# Optional: Show weather (comment out if not needed)
# weather
