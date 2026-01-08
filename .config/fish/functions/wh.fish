function wh
    set -l cmd (string join " " -- $argv)
    command watch -tbcd "$cmd | ccze -A"
end
