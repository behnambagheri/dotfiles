function sudo
    if test "$argv[1]" = "vim"
        command sudo -E nvim $argv[2..-1]  # Run nvim instead of vim while preserving the environment
    else
#         command sudo -E $argv  # Run all other sudo commands normally while preserving the environment
        command sudo $argv  # Run all other sudo commands normally while preserving the environment
    end
end
