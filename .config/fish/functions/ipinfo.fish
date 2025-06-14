function ipinfo
    if test (count $argv) -eq 0
        # Fetch data from both APIs
        set data1 (curl -s -H 'Accept: application/json' "ip.bea.sh")
        set data2 (curl -s -H 'Accept: application/json' "tnedi.me/json")

        # Extract IP addresses
        set ip1 (echo $data1 | jq -r '.ip')
        set ip2 (echo $data2 | jq -r '.ip')

        # Compare IPs and format JSON output
        if test "$ip1" = "$ip2"
            echo '{
  "ip.bea.sh":' (echo $data1 | jq 'del(.user_agent, .ip_decimal, .country_eu, .region_code, .latitude, .longitude, .time_zone, .asn)') '
}' | jq .
        else
            echo '{
  "ip.bea.sh":' (echo $data1 | jq 'del(.user_agent, .ip_decimal, .country_eu, .region_code, .latitude, .longitude, .time_zone, .asn)') ',
  "ident.me":' (echo $data2 | jq 'del(.user_agent, .ip_decimal, .country_eu, .region_code, .latitude, .longitude, .tz, .weather, .postal, .asn, .continent)') '
}' | jq .
        end
    else if string match -q -r '^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$' -- $argv[1]
        curl -s -H 'Accept: application/json' "ip.bea.sh/?ip=$argv[1]" | jq 'del(.user_agent, .ip_decimal, .country_eu, .region_code, .latitude, .longitude, .time_zone, .asn)' | jq .
    else
        set ip (dig +short $argv[1] | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)
        curl -s -H 'Accept: application/json' "ip.bea.sh/?ip=$ip" | jq 'del(.user_agent, .ip_decimal, .country_eu, .region_code, .latitude, .longitude, .time_zone, .asn)' | jq .
    end
end
