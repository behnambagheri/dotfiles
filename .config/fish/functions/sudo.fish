function sudo
    if count $argv
        switch $argv[1]
            case l
                command sudo lsd -lh $argv[2..-1]
            case vim
                command sudo hx $argv[2..-1]
            case '*'
                command sudo $argv
        end
    else
        command sudo
    end
end
