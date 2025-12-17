if status is-interactive
    fish_add_path $HOME/.local/bin $HOME/bin
    set -gx EDITOR nvim
    fish_config theme choose "kanagawa_dragon"
end
