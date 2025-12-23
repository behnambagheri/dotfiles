# Exclude SSH sessions from notifications
set -U __done_exclude '^git (?!push|pull|fetch)' '^ssh' '^vim' '^sudo -Es' '^sudo su -' '^sudo vim' '^sudo crontab' '^crontab' '^watch' '^tail' '^sudo tail' '^kubectl exec' '^docker logs' '^docker compose logs' '^sudo docker logs' '^sudo docker compose logs' '^nvim' '^kubectl logs -f' '^kubectl get pods -o wide --watch' '^sudo -s$' '^htop$' '^glances$' '^bash$' '^sudo nvim' '^kubectl logs -f' '^docker compose stats$' '^docker stats$' '^kubectl edit' '^kubectl get pods --watch' '^sudo journalctl -xefu' '^journalctl -xefu' '^ncdu' '^man ' '^sudo ncdu ' '^knc' '^history' '^kubectl-ai' '^hx' '^sudo hx' '^codex' '^sudo multitail' '^multitail' '^zsh' '^bat'
# set -U __done_exclude '^(git (?!push|pull|fetch)|ssh|vim|nvim|sudo -Es|sudo su -|sudo (vim|crontab)|crontab|watch|tail|sudo tail|kubectl exec|docker (logs|compose logs)|sudo docker (logs|compose logs)|less|more|cat|journalctl|dmesg|htop|top|iotop|bmon|glances|man|ncdu|tmux|screen|nvim)$'
set -U __done_min_cmd_duration 29000 # default: 5000 ms
set -U __done_allow_nongraphical 1

set -Ux PREFERRED_EDITOR hx
set -Ux EDITOR $PREFERRED_EDITOR
set -Ux VISUAL $PREFERRED_EDITOR

set -Ux TERM xterm-256color
set -Ux COLORTERM truecolor

set -Ux VIRTUAL_ENV_DISABLE_PROMPT 1
set -Ux VIRTUAL_ENV_DISABLE_PROMPT true
set -Ux VIRTUAL_ENV_DISABLE_PROMPT True

# set -Ux fifc_editor hx
# set -U fifc_bat_opts --style=numbers
# set -U fifc_fd_opts --hidden
# set -U fifc_fd_opts 
# set -U fifc_bat_opts --style="full"
# set -U fifc_keybinding \cg

#Only completing at the end of the line
set -U pisces_only_insert_at_eol 1

# set -Ux KUBECONFIG /Users/behnam/.kube/aircodeup.yaml:/Users/behnam/.kube/arvan.yaml:/Users/behnam/.kube/delta.yaml:/Users/behnam/.kube/novin.yaml:/Users/behnam/.kube/ilka.yaml:/Users/behnam/.kube/max-ir-central1-arvan.yaml:/Users/behnam/.kube/bea.yaml:
set -Ux KUBECONFIG /Users/behnam/.kube/delta.yaml:/Users/behnam/.kube/novin.yaml:/Users/behnam/.kube/asiatech-bea.yaml:/Users/behnam/.kube/maxdigital.yaml:/Users/behnam/.kube/frankfurt-bea.yaml:
test -e {$HOME}/.iterm2_shell_integration.fish; and source {$HOME}/.iterm2_shell_integration.fish

# Load kubectl completions only if kubectl exists
if command -q kubectl
    kubectl completion fish >~/.config/fish/completions/kubectl.fish
end

# Add /Users/behnam/.local/bin to PATH if it exists
if test -d /Users/behnam/.local/bin
    set -Ux PATH $PATH /Users/behnam/.local/bin
end

set -U fish_user_paths $HOME/.local/bin $fish_user_paths

# Add ~/bin to PATH if present
if test -d $HOME/bin
    fish_add_path --global --move --path $HOME/bin
end

source ~/.config/fish/conf.d/fzf.fish
# source ~/.config/fish/conf.d/fifc.fish
# source ~/.config/fish/conf.d/forgit.plugin.fish
#
# Homebrew environment without calling /bin/ps
#
if test (hostname) = Bagheri-MacBook-Pro.local

    eval (/opt/homebrew/bin/brew shellenv fish)
    set --global --export HOMEBREW_PREFIX /opt/homebrew

    set --global --export HOMEBREW_CELLAR /opt/homebrew/Cellar

    set --global --export HOMEBREW_REPOSITORY /opt/homebrew

    fish_add_path --global --move --path /opt/homebrew/bin /opt/homebrew/sbin

    if test -n "$MANPATH[1]"
        set --global --export MANPATH '' $MANPATH
    end

    if not contains /opt/homebrew/share/info $INFOPATH
        set --global --export INFOPATH /opt/homebrew/share/info $INFOPATH
    end
end

set -Ux TELEGRAM_CHAT_ID 323101679
set -Ux TELEGRAM_API_URL 'https://tg.bea.sh'
set -Ux PASTEGRAM_HOSTNAME true
set -Ux PASTEGRAM_LAST_COMMAND true

sync_history
