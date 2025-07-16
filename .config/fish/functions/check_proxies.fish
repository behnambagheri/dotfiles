function check_proxies
    for port in 7890 7891 7892
        set -l ip (curl --silent --fail --connect-timeout 3 --max-time 5 --proxy 127.0.0.1:$port ipinfo.io 2>/dev/null | grep '"ip"' | awk '{print $2}' | cut -d"," -f1)
        
        if test -z "$ip"
            set -g proxy_$port "False"
        else
            set -g proxy_$port $ip
        end
        
        echo "Proxy 127.0.0.1:$port → $ip"
    end
end
