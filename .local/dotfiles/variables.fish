# Exclude SSH sessions from notifications
# set -U __done_exclude '^git (?!push|pull|fetch)'  '^ssh' '^vim' '^sudo -Es' '^sudo su -' '^sudo vim' '^sudo crontab' '^crontab' '^watch' '^tail' '^sudo tail' '^kubectl exec' '^docker logs' '^docker compose logs' '^sudo docker logs' '^sudo docker compose logs'
set -U __done_exclude '^(git (?!push|pull|fetch)|ssh|vim|sudo -Es|sudo su -|sudo (vim|crontab)|crontab|watch|tail|sudo tail|kubectl exec|docker (logs|compose logs)|sudo docker (logs|compose logs)|less|more|cat|journalctl|dmesg|htop|top|iotop|bmon|glances|man|ncdu|tmux|screen)$'
set -U __done_min_cmd_duration 5000  # default: 5000 ms
set -U __done_allow_nongraphical 1
