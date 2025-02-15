function config-update
    set use_proxy false
    set use_public_proxy false

    # Parse arguments
    for arg in $argv
        if test "$arg" = "--with-proxy"
            set use_proxy true
        else if test "$arg" = "--public-proxy"
            set use_public_proxy true
        end
    end

    # Run the config pull command
    config pull

    # Execute the main script
    bash ~/.local/dotfiles/config_installer.sh

    # Apply proxy settings if needed
    if test "$use_proxy" = true
        echo "Applying proxy settings..."
        # Add proxy setup commands here
    end

    if test "$use_public_proxy" = true
        echo "Applying public proxy settings..."
        # Add public proxy setup commands here
    end
end
