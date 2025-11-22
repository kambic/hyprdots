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
  fzf-tab
  # you-should-use
  colored-man-pages
  copyfile
  # copypath
  # dirhistory
  # web-search
)
# FZF configuration
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
if command -v bat &>/dev/null; then
  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --preview 'bat --color=always {} 2>/dev/null || cat {}'"
else
  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --preview 'cat {}'"
fi

export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"

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

# ===== Environment Variables =====
export EDITOR='nvim'
export VISUAL="$EDITOR"
export PAGER='less'

# Python development
export PYTHONSTARTUP="$HOME/.pythonrc"

autoload -Uz compinit
compinit

source <(fzf --zsh)
# starship init zsh
# Optional: Show weather (comment out if not needed)
# weather
