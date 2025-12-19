if status is-interactive
    fish_add_path $HOME/.local/bin $HOME/bin
    set -gx EDITOR nvim
    fish_config theme choose "kanagawa_dragon"

    set -gx FZF_DEFAULT_OPTS "\
        --color=fg:-1,fg+:#c5c9c5,bg:-1,bg+:#2d4f67 \
        --color=hl:#8a9a7b,hl+:#8a9a7b,info:#b98d7b,marker:#87a987 \
        --color=prompt:#a292a3,spinner:#c4746e,pointer:#7fb4ca,header:#7aa89f \
        --color=border:#c5c9c5,label:#a6a69c,query:#c5c9c5"
end
