DISABLE_AUTO_UPDATE="true"
# The following lines were added by compinstall

# zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
# zstyle :compinstall filename '/home/archie/.zshrc'

HISTFILE=~/.histfile
HISTSIZE=5000
SAVEHIST=5000
#bindkey -e
# Oh-my-zsh installation path
ZSH=~/.oh-my-zsh
# List of plugins used
plugins=(
  chezmoi 
  docker 
  docker-compose 
  fabric qrcode 
  uv 
  sudo 
  supervisor 
  starship 
  zsh-autosuggestions 
  zsh-syntax-highlighting 
)
source $ZSH/oh-my-zsh.sh
source ~/.aliases
source <(fzf --zsh)
