if status is-interactive
    # Commands to run in interactive sessions can go here
    source ~/.local/dotfiles/variables.fish
    source ~/.config/fish/conf.d/fzf.fish
end

# if set -q SSH_TTY
#     if test (tty) = $SSH_TTY
#         echo "Welcome to the server!"
#         uptime
#         cat /home/bea/.local/dotfiles/variables.fish | source
#         source ~/.local/dotfiles/variables.fish
#     end
# end
