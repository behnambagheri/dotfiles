function sudo
    if test (count $argv) -gt 0
        switch $argv[1]
            case l
                set args $argv[2..-1]
                command sudo lsd -lh $args
            case vim
                set args $argv[2..-1]
                command sudo hx $args
            case '*'
                command sudo $argv
        end
    else
        command sudo
    end
end
