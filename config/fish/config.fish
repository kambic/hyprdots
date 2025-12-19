if status is-interactive
    function y
        set tmp (mktemp -t "yazi-cwd.XXXXXX")
        yazi $argv --cwd-file="$tmp"
        if read -z cwd < "$tmp"; and [ -n "$cwd" ]; and [ "$cwd" != "$PWD" ]
            builtin cd -- "$cwd"
        end
        rm -f -- "$tmp"
    end
		set POSH agnoster
		oh-my-posh init fish | source

function vv
    set -l cache_file ~/.cache/vv_last_nvim

    # Ensure cache dir exists
    mkdir -p ~/.cache

    # Load last selection if it exists
    set -l last ""
    if test -f $cache_file
        set last (cat $cache_file)
    end

    # Select config
    set -l config (
        fd --max-depth 1 --glob 'nvim-*' ~/.config \
        | sort \
        | fzf \
            --prompt="Neovim Configs > " \
            --height=50% \
            --layout=reverse \
            --border \
            --exit-0 
    )

    # If nothing selected, exit
    if test -z "$config"
        echo "No config selected"
        return
    end

    # Cache selection
    echo $config > $cache_file

    # Launch Neovim with selected config
    set -l appname (basename "$config")
    env NVIM_APPNAME=$appname nvim $argv
end


# -----------------------------------------------------
end
