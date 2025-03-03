# Exclude SSH sessions from notifications
set -U __done_exclude '^git (?!push|pull|fetch)'  '^ssh' '^vim'   '^sudo -Es' '^sudo su -' '^sudo vim' '^sudo crontab' '^crontab' '^watch' '^tail' '^sudo tail' '^kubectl exec' '^docker logs' '^docker compose logs' '^sudo docker logs' '^sudo docker compose logs' '^nvim' '^kubectl logs -f' '^kubectl get pods -o wide --watch' '^sudo -s$' '^htop$' '^glances$' '^bash$' '^sudo nvim' '^kubectl logs -f' '^docker compose stats$' '^docker stats$' '^kubectl edit' '^kubectl get pods --watch' '^sudo journalctl -xefu' '^journalctl -xefu' '^ncdu' '^man ' '^sudo ncdu '
# set -U __done_exclude '^(git (?!push|pull|fetch)|ssh|vim|nvim|sudo -Es|sudo su -|sudo (vim|crontab)|crontab|watch|tail|sudo tail|kubectl exec|docker (logs|compose logs)|sudo docker (logs|compose logs)|less|more|cat|journalctl|dmesg|htop|top|iotop|bmon|glances|man|ncdu|tmux|screen|nvim)$'
set -U __done_min_cmd_duration 29000  # default: 5000 ms
set -U __done_allow_nongraphical 1

set -Ux PREFERRED_EDITOR nvim
set -Ux EDITOR $PREFERRED_EDITOR
set -Ux VISUAL $PREFERRED_EDITOR

#Only completing at the end of the line
set -U pisces_only_insert_at_eol 1
