function ipinfo
if string match -q -r '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' -- $argv[1]
    curl -s -H 'Accept: application/json' "ip.bea.sh/?ip=$argv[1]" | jq .
else
    set ip (dig +short $argv[1] | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
    curl -s -H 'Accept: application/json' "ip.bea.sh/?ip=$ip" | jq .
end
end
