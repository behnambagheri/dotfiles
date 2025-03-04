function config-update
    config pull && bash ~/.local/dotfiles/config_installer.sh $argv && fisher remove meaningful-ooo/sponge gazorby/fish-abbreviation-tips 2> /dev/null
end
