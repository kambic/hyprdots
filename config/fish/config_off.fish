# Fish Configuration
# by Saifullah Balghari 
# -----------------------------------------------------

# Remove the fish greetings
set -g fish_greeting

# Start neofetch
# neofetch

# Sets starship as the promt
# eval (starship init fish)

# Start atuin
# atuin init fish | source
# -----------------------------------------------------
# CUSTOMIZATION
# -----------------------------------------------------
oh-my-posh init fish | source
# -----------------------------------------------------
# Prompt
# -----------------------------------------------------
# eval "$($HOME/.local/bin/oh-my-posh init fish --config $HOME/.config/ohmyposh/EDM115-newline.omp.json)"
# List Directory
alias l='eza -lh  --icons=auto' # long list
alias ls='eza -1   --icons=auto' # short list
alias ll='eza -lha --icons=auto --sort=name --group-directories-first' # long list all
alias ld='eza -lhD --icons=auto' # long list dirs
alias lt='eza --icons=auto --tree' # list folder as tree

function y
    set tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if read -z cwd <"$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
        builtin cd -- "$cwd"
    end
    rm -f -- "$tmp"
end


# ===== Path Setup =====
fish_add_path ~/bin

# ===== Environment Variables =====
set -gx EDITOR nvim
set -gx VISUAL $EDITOR

# ===== Abbreviations (Fish equivalent of aliases) =====
# Navigation
abbr -a .. 'cd ..'
abbr -a ... 'cd ../..'
abbr -a .... 'cd ../../..'

# Modern replacements
if command -q exa
    abbr -a ls 'exa --icons'
    abbr -a ll 'exa -alF --icons'
    abbr -a la 'exa -A --icons'
    abbr -a lt 'exa -T --icons'
else
    abbr -a ls 'ls --color=auto'
    abbr -a ll 'ls -alF'
    abbr -a la 'ls -A'
end

if command -q bat
    abbr -a cat 'bat'
end

if command -q duf
    abbr -a df 'duf'
end

if command -q procs
    abbr -a ps 'procs'
end


# Docker
abbr -a dps 'docker ps'
abbr -a dpsa 'docker ps -a'
abbr -a di 'docker images'
abbr -a drm 'docker rm'
abbr -a drmi 'docker rmi'
abbr -a dcu 'docker-compose up'
abbr -a dcd 'docker-compose down'

abbr -a pyclean 'find . -type f -name "*.py[co]" -delete; and find . -type d -name "__pycache__" -delete'

# ===== Functions =====
# Quick directory navigation with fzf
function fz
    set -l dir
    if command -q fd
        set dir (fd --type d --hidden --follow --exclude .git | fzf --height 40% --reverse)
    else
        set dir (find . -type d -not -path "*/\.git/*" | fzf --height 40% --reverse)
    end
    if test -n "$dir"
        cd "$dir"
    end
end

# Enhanced git log with fzf
function glf
    if not git rev-parse --is-inside-work-tree >/dev/null 2>&1
        echo "Not a git repository"
        return 1
    end
    
    set -l commit_hash (git log --color=always --format="%C(auto)%h %s %C(blue)%cr" | fzf --ansi --no-sort --reverse | string match -r '^[a-f0-9]*')
    if test -n "$commit_hash"
        git show "$commit_hash"
    end
end

# Weather information
function weather
    curl -s "wttr.in/($argv[1] || echo Brussels)?1"
end

# Extract various file types
function extract
    if test -f $argv[1]
        switch $argv[1]
            case *.tar.bz2
                tar xjf $argv[1]
            case *.tar.gz
                tar xzf $argv[1]
            case *.bz2
                bunzip2 $argv[1]
            case *.rar
                unrar x $argv[1]
            case *.gz
                gunzip $argv[1]
            case *.tar
                tar xf $argv[1]
            case *.tbz2
                tar xjf $argv[1]
            case *.tgz
                tar xzf $argv[1]
            case *.zip
                unzip $argv[1]
            case *.Z
                uncompress $argv[1]
            case *.7z
                7z x $argv[1]
            case '*'
                echo "'$argv[1]' cannot be extracted via extract"
        end
    else
        echo "'$argv[1]' is not a valid file"
    end
end

# Yazi file manager wrapper
function yy
    set -l tmp (mktemp -t "yazi-cwd.XXXXXX")
    yazi $argv --cwd-file="$tmp"
    if set -l cwd (command cat "$tmp" 2>/dev/null); and test -n "$cwd"; and test "$cwd" != "$PWD"
        cd "$cwd"
    end
    rm -f "$tmp"
end



# ===== Plugins =====
# Fisher plugin manager (install if not present)
# if not functions -q fisher
#     curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source
#     and fisher update
# end

# Plugin list (install with: fisher install <name>)
# set -g fisher_path ~/.local/share/fisher
# set -g fish_plugins \
#     jethrokuan/z \
#     PatrickF1/fzf.fish \
#     edc/bass \
#     jorgebucaran/autopair.fish

# ===== Key Bindings =====
# FZF key bindings
# if command -q fzf
#     fzf_configure_bindings --directory=\cp --variables=\e\cv --processes=\ep
# end

# ===== Startup =====
# Welcome message
if status is-interactive
    # Show system info
    if command -q neofetch
        neofetch
    else if command -q fastfetch
        fastfetch
    end
end

# ===== Local Config =====
# Source local fish config if exists
if test -f ~/.config/fish/config.local.fish
    source ~/.config/fish/config.local.fish
end
