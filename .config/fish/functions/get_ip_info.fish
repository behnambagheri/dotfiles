function get_ip_info
    curl -4 -s ip.bea.sh/json | tee /tmp/ipinfo.json && chmod 777 /tmp/ipinfo.json 
end
