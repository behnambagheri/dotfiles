function ipinfo
curl -s -H 'Accept: application/json' "ip.bea.sh/?ip=$argv" | jq .
end
