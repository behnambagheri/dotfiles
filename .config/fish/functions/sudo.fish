function sudo
    if test (count $argv) -gt 0
        switch $argv[1]
            case l
                command sudo lsd -lh --total-size --group-directories-first $argv[2..-1]
            case ld
                command sudo lsd -lh --total-size --group-directories-first --git --tree --depth 2 $argv[2..-1]
            case vim
                command sudo hx $argv[2..-1]
            case '*'
                command sudo $argv
        end
    else
        command sudo
    end
end
