# shellcheck disable=SC1090

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Load bash completion if available
[[ -r /usr/share/bash-completion/bash_completion ]] && . /usr/share/bash-completion/bash_completion
# Less pager settings
export LESS='-R --quit-if-one-screen --ignore-case --LONG-PROMPT --RAW-CONTROL-CHARS --HILITE-UNREAD --tabs=4 --no-init --window=-4'

# Git prompt setup - Arch-specific path
if [ -f /usr/share/git/completion/git-prompt.sh ]; then
  source /usr/share/git/completion/git-prompt.sh
fi

get_os() {
  os_info=$(cat /etc/os-release)
  os_name=$(echo "$os_info" | grep -oP '^NAME="?(.+)"?$' | sed 's/^NAME=//;s/"//g')
  echo "$os_name"
}

function bash_prompt {
  # Set color to green
  PS1="\[\e[32m\]"

  # Add OS name
  PS1+=$(get_os)" "

  # Reset color
  PS1+="\[\e[0m\]"

  # Add current working directory
  PS1+="\w"

  # Set color to yellow for git prompt
  PS1+="\[\e[33m\]"

  # Add git prompt (assuming you have a function or command for this)
  PS1+="$(git_prompt)"

  # Reset color
  PS1+="\[\e[0m\]"

  # Add prompt symbol
  PS1+=" > "
}

# Example git prompt function (you can customize this)
git_prompt() {
  git branch 2>/dev/null | grep '^\*' | sed 's/^\* / (/;s/$/)/'
}

vim() {
  if [ -w "$1" ] || [ ! -e "$1" ]; then
    nvim "$@"
  else
    sudoedit "$@"
  fi
}

# Set the prompt
PROMPT_COMMAND=bash_prompt

# Prompt configuration with git integration
# PS1='\[\033[32m\]EOS \[\033[0m\]\w\[\033[33m\]$(__git_ps1 " %s")\[\033[0m\] > '

# General alias
alias cls='clear'
# bind 'Control-l: clear-screen'
alias ..='cd ..'
# alias rm='rm -i'
# alias mv='mv -i'
# alias cp='cp -i'
# alias cd='z'
alias ls='lsd -lah --group-directories-first --color=auto'
alias top='btop'
# alias cat='bat'
alias fd='fd -H --max-depth 4'
alias zj='zellij'

# Systemctl alias
alias sysstat='systemctl status'
alias sysen='systemctl enable'
alias sysdis='systemctl disable'

HISTFILE=~/.histfile
HISTSIZE=5000
SAVEHIST=5000

source ~/.aliases
source <(fzf --bash)
