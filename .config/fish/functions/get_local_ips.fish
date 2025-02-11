function get_local_ips
    set OS_TYPE (uname)

    if test "$OS_TYPE" = "Linux"
        /usr/sbin/ip -4 a | sed '/docker0:/,+2 d' | sed '/ br-/,+2 d' | sed '/ vmnet/,+2 d' |
          sed -ne '/127.0.0.1/!{s/^[ \t]*inet[ \t]*\([0-9.]\+\)\/.*$/\1/p}'
    else if test "$OS_TYPE" = "Darwin"
        ifconfig | awk '/inet / && $2 != "127.0.0.1" {print $2}'
    end
end
