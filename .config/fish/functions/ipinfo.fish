function ipinfo
if string match -q -r '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' -- $argv[1]
    curl -s -H 'Accept: application/json' "ip.bea.sh/?ip=$argv[1]" | jq 'del(.user_agent, .ip_decimal, .country_eu, .region_code, .latitude, .longitude)' 
else
    set ip (dig +short $argv[1] | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
    curl -s -H 'Accept: application/json' "ip.bea.sh/?ip=$ip" | jq 'del(.user_agent, .ip_decimal, .country_eu, .region_code, .latitude, .longitude)' 
end
end
