if status is-interactive
    # Commands to run in interactive sessions can go here
    source ~/.local/dotfiles/variables.fish
end

if set -q SSH_TTY
    echo "Welcome, you are connected via SSH!"
    uptime

    source ~/.local/dotfiles/variables.fish
end
