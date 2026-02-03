function whf
    set -l cmd (string join " " -- $argv)
    command watch -tbcd "fish -c $cmd | ccze -A"
end
