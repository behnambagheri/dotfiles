function config-update
    config pull && bash ~/.local/dotfiles/config_installer.sh && fisher remove meaningful-ooo/sponge gazorby/fish-abbreviation-tips 2> /dev/null
end
