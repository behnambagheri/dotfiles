# Exclude SSH sessions from notifications
set -U __done_exclude '^git (?!push|pull|fetch)'  '^ssh' '^vim'   '^sudo -Es' '^sudo su -' '^sudo vim' '^sudo crontab' '^crontab' '^watch' '^tail' '^sudo tail' '^kubectl exec' '^docker logs' '^docker compose logs' '^sudo docker logs' '^sudo docker compose logs' '^nvim' '^kubectl logs -f' '^kubectl get pods -o wide --watch' '^sudo -s$' '^htop$' '^glances$' '^bash$' '^sudo nvim' '^kubectl logs -f' '^docker compose stats$' '^docker stats$' '^kubectl edit' '^kubectl get pods --watch' '^sudo journalctl -xefu' '^journalctl -xefu' '^ncdu' '^man ' '^sudo ncdu '
# set -U __done_exclude '^(git (?!push|pull|fetch)|ssh|vim|nvim|sudo -Es|sudo su -|sudo (vim|crontab)|crontab|watch|tail|sudo tail|kubectl exec|docker (logs|compose logs)|sudo docker (logs|compose logs)|less|more|cat|journalctl|dmesg|htop|top|iotop|bmon|glances|man|ncdu|tmux|screen|nvim)$'
set -U __done_min_cmd_duration 29000  # default: 5000 ms
set -U __done_allow_nongraphical 1

set -Ux PREFERRED_EDITOR nvim
set -Ux EDITOR $PREFERRED_EDITOR
set -Ux VISUAL $PREFERRED_EDITOR

set -Ux fifc_editor nvim
# set -U fifc_bat_opts --style=numbers
# set -U fifc_fd_opts --hidden
# set -U fifc_fd_opts 
# set -U fifc_bat_opts --style="full"
set -U fifc_keybinding \cg

#Only completing at the end of the line
set -U pisces_only_insert_at_eol 1

set -Ux KUBECONFIG /Users/behnam/.kube/aircodeup.yaml:/Users/behnam/.kube/arvan.yaml:/Users/behnam/.kube/delta.yaml:/Users/behnam/.kube/novin.yaml

test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish


# Load kubectl completions only if kubectl exists
if command -q kubectl
    kubectl completion fish > ~/.config/fish/completions/kubectl.fish
end


# Add /Users/behnam/.local/bin to PATH if it exists
if test -d /Users/behnam/.local/bin
    set -Ux PATH $PATH /Users/behnam/.local/bin
end


# Add /Users/behnam/.local/bin to PATH if it exists
if test -d /home/bea/.local/bin
    set -Ux PATH $PATH /home/bea/.local/bin
end

set -U fish_user_paths $HOME/.local/bin $fish_user_paths


# source ~/.config/fish/conf.d/fzf.fish
# source ~/.config/fish/conf.d/fifc.fish
# source ~/.config/fish/conf.d/forgit.plugin.fish


