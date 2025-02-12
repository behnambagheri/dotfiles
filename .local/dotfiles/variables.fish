# Exclude SSH sessions from notifications
set -U __done_exclude '^git (?!push|pull|fetch)'  '^ssh' '^vim' '^sudo -Es'
set -U __done_min_cmd_duration 5000  # default: 5000 ms
set -U __done_allow_nongraphical 1
