function get_ip_info
    curl -4 -s ip.bea.sh/json | tee /tmp/ipinfo.json 2> /dev/null && chmod 777 /tmp/ipinfo.json 
end
