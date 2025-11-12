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

# Enhanced plugin list
plugins=(
  # Core utilities
  git
  sudo
  supervisor
  docker
  docker-compose
  fabric

  # Development tools
  uv
  rust
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
  jsontools
)

# ===== Plugin Configuration =====
# Zsh Autosuggestions
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_USE_ASYNC=true
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=8"

# Zsh Syntax Highlighting
ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern cursor root)
ZSH_HIGHLIGHT_STYLES[cursor]='bold'

# FZF configuration
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --color=always {} 2>/dev/null || cat {}'"
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"

# ===== Load Oh My Zsh =====
source $ZSH/oh-my-zsh.sh

# ===== Custom Functions =====
# Quick directory navigation with fzf
function fz() {
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git 2>/dev/null | fzf --height 40% --reverse --preview 'exa -T --level=2 {}') && cd "$dir"
}

# Enhanced git log with fzf
function glf() {
  git log --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" | fzf --ansi --no-sort --reverse --tiebreak=index --preview 'f() { set -- $(echo -- "$@" | grep -o "[a-f0-9]\{7\}"); [ -n "$1" ] && git show --color=always $1; }; f {}' | grep -o "[a-f0-9]\{7\}" | head -1 | xargs -I % git show %
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
  $EDITOR "$filename"
}

# Weather information
function weather() {
  curl "wttr.in/${1:-Brussels}?1"
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
fi

if command -v bat &>/dev/null; then
  alias cat='bat'
fi

if command -v duf &>/dev/null; then
  alias df='duf'
fi

if command -v procs &>/dev/null; then
  alias ps='procs'
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
alias pip='uv pip' # Use uv for pip if available
alias venv='python -m venv .venv && source .venv/bin/activate'

# ===== Environment Variables =====
export EDITOR='nvim' # or 'vim', 'code', etc.
export VISUAL='$EDITOR'
export PAGER='less'
export BROWSER='firefox'

# Python development
export PYTHONSTARTUP="$HOME/.pythonrc"
export PIP_REQUIRE_VIRTUALENV=false

# Node.js
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" # This loads nvm

# Rust
export PATH="$HOME/.cargo/bin:$PATH"

# Go
export PATH="$HOME/go/bin:$PATH"

# Local bin directory
export PATH="$HOME/.local/bin:$PATH"

# ===== Completions =====
# Additional completions
if command -v brew &>/dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
fi

autoload -Uz compinit
compinit

# ===== FZF Integration =====
# Enhanced fzf key bindings
source <(fzf --zsh)

# Custom fzf functions
function fzf-file-widget() {
  LBUFFER="${LBUFFER}$(fd --type f --hidden --follow --exclude .git 2>/dev/null | fzf --height 40% --reverse --preview 'bat --color=always {}')"
  zle redisplay
}
zle -N fzf-file-widget
bindkey '^F' fzf-file-widget

function fzf-cd-widget() {
  local dir
  dir=$(fd --type d --hidden --follow --exclude .git 2>/dev/null | fzf --height 40% --reverse --preview 'exa -T --level=2 {}') && cd "$dir"
  zle reset-prompt
}
zle -N fzf-cd-widget
bindkey '^P' fzf-cd-widget

# ===== Starship Prompt =====
eval "$(starship init zsh)"

# ===== Startup Messages =====
# Only show on first terminal launch
if [ -z "$TERM_PROGRAM" ]; then
  echo "🚀 Zsh loaded with $(($(date +%s) - ${STARTUP_TIME:-0}))s"
  weather
fi

# ===== Final Setup =====
# Disable Oh My Zsh auto-update to prevent slowdowns
zstyle ':omz:update' mode disabled

# Enable color support
autoload -Uz colors && colors

# Set terminal title
precmd() {
  echo -ne "\033]0;${PWD/#$HOME/~}\007"
}
