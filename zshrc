HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
# ===== Oh My Zsh Configuration =====
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="" # Disable OMZ themes since we're using Starship

# Safe plugin list - only include plugins that are definitely installed
plugins=(
  # Core utilities
  git
  sudo
  # supervisor
  docker
  docker-compose

  # Development tools
  python
  npm
  node
  starship

  # Modern enhancements
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
  # fzf-tab
  # you-should-use
  # colored-man-pages
  # copyfile
  # copypath
  # dirhistory
  # web-search
)
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


# Weather information
function weather() {
  curl -s "wttr.in/${1:-Brussels}?1"
}

# ===== Aliases =====
# Source custom aliases if exists
source ~/.aliases

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

alias cat='bat'

autoload -Uz compinit
compinit

source <(fzf --zsh)
# starship init zsh
# Optional: Show weather (comment out if not needed)
# weather
