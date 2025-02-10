#!/bin/bash
##Install:
#bash <(GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" git clone git@github.com:behnambagheri/dotfiles.git /tmp/dotfiles && echo /tmp/dotfiles/.local/dotfiles/config_installer.sh)
##Update:
#config pull && bash .local/dotfiles/config_installer.sh

set -e  # Exit on error


INSTALL_PROXY=false
PUBLIC_PROXY=false

# Parse script arguments
for arg in "$@"; do
    case "$arg" in
        --with-proxy)
            INSTALL_PROXY=true
            ;;
        --public-proxy)
            PUBLIC_PROXY=true
            INSTALL_PROXY=true  # Ensure --with-proxy tasks are also executed
            ;;
    esac
done

echo "Updating system and installing the latest Fish shell..."
if [[ "$(uname -s)" == "Linux" ]]; then
    if command -v apt &>/dev/null; then
        sudo apt-add-repository ppa:fish-shell/release-3 -y
        sudo apt install -y fish curl git bat fdclone vim glances curl wget dnsutils bind9-host nmap iputils-ping rsync netcat-traditional gcc build-essential net-tools iproute2 unzip bind9-* prometheus-node-exporter ncdu nethogs rkhunter chkrootkit ncdu 
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y fish curl git bat fd-find vim util-linux-user tar 
    elif command -v pacman &>/dev/null; then
        sudo pacman -S --noconfirm fish curl git bat fdclone vim
    fi
elif [[ "$(uname -s)" == "Darwin" ]]; then
    brew install fish curl git vim bat fdclone
fi

# Install fzf (Fuzzy Finder)
echo "Installing fzf..."
if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
else
    echo "fzf already exists, skipping clone."
fi

~/.fzf/install --all


# Check if Fish shell is installed before proceeding
if command -v fish &>/dev/null; then
    echo "Fish installed successfully: $(fish --version)"
else
    echo "Error: Fish installation failed!"
    exit 1
fi

# Change the default shell to Fish (only if necessary)
if [[ "$SHELL" != "$(which fish)" ]]; then
    echo "Setting Fish as default shell..."
    chsh -s "$(which fish)"
fi

# Configure Fish
echo "Configuring Fish..."
fish -c 'set -U fish_greeting ""'

# Install Oh My Fish (OMF) if not already installed
if [ ! -d "$HOME/.local/share/omf" ]; then
    echo "Installing Oh My Fish..."
    curl -L https://get.oh-my.fish | fish
fi

# Install OMF theme
fish -c 'omf install lambda'

# Clone dotfiles repository if it doesn't exist
if [ ! -d "$HOME/.dotfiles" ]; then
    echo "Cloning dotfiles repository..."
    #git clone --bare git@github.com:behnambagheri/dotfiles.git "$HOME/.dotfiles"
    git clone --bare https://github.com/behnambagheri/dotfiles.git "$HOME/.dotfiles"
else
    echo "Dotfiles repository already exists, skipping clone."
fi

# Configure Git to ignore untracked files
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME config --local status.showUntrackedFiles no

# Hard reset dotfiles to repo state
git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME reset --hard


# Define `config` function for managing dotfiles
#echo "Creating 'config' function for Git-managed dotfiles..."
#fish -c 'function config; git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME $argv; end'
#fish -c 'funcsave config'

# Remove default Lambda theme prompt (if it exists)
rm -f "$HOME/.local/share/omf/themes/lambda/functions/fish_right_prompt.fish"
rm -f "$HOME/.local/share/omf/themes/lambda/functions/fish_prompt.fish"


# Ensure the target directory exists before symlinking
mkdir -p "$HOME/.local/share/omf/themes/lambda/functions"
ln -sf "$HOME/.local/dotfiles/fish_prompt.fish" "$HOME/.local/share/omf/themes/lambda/functions/fish_prompt.fish"

# Install Fisher (if not already installed)
if ! fish -c "functions -q fisher"; then
    echo "Installing Fisher..."
#    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
    fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
fi

# Install Fisher plugins
echo "Installing Fisher plugins..."

fish -c "fisher install jorgebucaran/fisher"
fish -c "fisher install meaningful-ooo/sponge"
fish -c "fisher install jhillyerd/plugin-git"
fish -c "fisher install gazorby/fish-abbreviation-tips"
fish -c "fisher install jethrokuan/z"
fish -c "fisher install patrickf3139/colored-man-pages"
fish -c "fisher install markcial/upto"
fish -c "fisher install jorgebucaran/autopair.fish"
fish -c "fisher install laughedelic/pisces"
fish -c "fisher install PatrickF1/fzf.fish"

# Install Docker plugins only if Docker is installed
if command -v docker &>/dev/null; then
    echo "Docker detected! Installing Docker plugins..."
    fish -c "fisher install asim-tahir/docker.fish"
    fish -c "fisher install brgmnn/fish-docker-compose"
    fish -c "fisher install asim-tahir/docker-compose.fish"
else
    echo "Docker not found. Skipping Docker plugins."
fi

# Install Kubernetes plugin only if kubectl is installed
if command -v kubectl &>/dev/null; then
    echo "kubectl detected! Installing Kubernetes plugin..."
    fish -c "fisher install blackjid/plugin-kubectl"
else
    echo "kubectl not found. Skipping Kubernetes plugin."
fi

# Install Homebrew completion plugin only on macOS
if [[ "$(uname -s)" == "Darwin" ]]; then
    echo "macOS detected! Installing Homebrew completions..."
    fish -c "fisher install laughedelic/brew-completions"
else
    echo "Not macOS. Skipping Homebrew completions."
fi

# Install Vim-Plug if not installed
if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
    echo "Installing Vim-Plug..."
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Install Vim plugins automatically
echo "Installing Vim plugins with PlugInstall..."
vim +PlugInstall +qall



# Define proxy settings
PROXY="socks5h://127.0.0.1:7890"

# APT Proxy Setup (For Debian-based systems)
setup_apt_proxy() {
    echo "Configuring APT proxy..."
    sudo bash -c "cat > /etc/apt/apt.conf.d/01proxy" <<EOF
Acquire::http::Proxy  "$PROXY";
Acquire::https::Proxy "$PROXY";
EOF
    echo "APT proxy configured successfully!"
}

# DNF/YUM Proxy Setup (For RedHat-based systems)
setup_dnf_yum_proxy() {
    echo "Configuring DNF/YUM proxy..."
    sudo bash -c "cat >> /etc/dnf/dnf.conf" <<EOF
proxy=$PROXY
EOF

    sudo bash -c "cat >> /etc/yum.conf" <<EOF
proxy=$PROXY
EOF

    echo "DNF/YUM proxy configured successfully!"
}


# Enable and Start Sing-box Service
enable_singbox_service() {
    echo "Enabling and starting Sing-box service..."
    if command -v systemctl &>/dev/null; then
        sudo systemctl enable --now sing-box
        sudo systemctl restart sing-box

        echo "Sing-box service started and enabled on boot."
    else
        echo "Error: systemctl not found. Unable to enable Sing-box service."
        exit 1
    fi
}



# Install Sing-box and configure proxy if `--with-proxy` is provided
if [ "$INSTALL_PROXY" = true ]; then
    echo "Installing Sing-box..."
    if command -v apt &>/dev/null; then
        echo "Detected Debian-based system. Installing Sing-box..."
        sudo mkdir -p /etc/apt/keyrings
        sudo curl -fsSL https://sing-box.app/gpg.key -o /etc/apt/keyrings/sagernet.asc
        sudo chmod a+r /etc/apt/keyrings/sagernet.asc
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/sagernet.asc] https://deb.sagernet.org/ * *" | \
            sudo tee /etc/apt/sources.list.d/sagernet.list > /dev/null
        sudo apt-get update
        sudo apt-get install -y sing-box

    elif command -v dnf &>/dev/null; then
        echo "Detected RedHat-based system. Installing Sing-box..."
        sudo dnf -y install dnf-plugins-core
        sudo dnf config-manager --add-repo https://sing-box.app/sing-box.repo
        sudo dnf install -y sing-box
    else
        echo "Unsupported package manager. Skipping Sing-box installation."
    fi


    # Define source and destination paths for configuration
    GIT_REPO="git@github.com:behnambagheri/lab.git"
    TEMP_DIR="/tmp/lab"
    CONFIG_SOURCE="$TEMP_DIR/var/www/subscription/sbox/routers.json"
    CONFIG_DEST="/etc/sing-box/config.json"
    
    # Clone the repository
    echo "Cloning repository from $GIT_REPO..."
    git clone "$GIT_REPO" "$TEMP_DIR"
    
    # Check if git clone was successful
    if [ $? -ne 0 ]; then
        echo "Error: Git clone failed."
        exit 1
    fi
    
    # Check if the configuration file exists
    if [ -f "$CONFIG_SOURCE" ]; then
        echo "Copying Sing-box configuration file..."
        sudo mkdir -p /etc/sing-box
        sudo cp "$CONFIG_SOURCE" "$CONFIG_DEST"
        echo "Configuration file copied successfully."
    else
        echo "Error: Configuration file not found at $CONFIG_SOURCE"
        rm -rf "$TEMP_DIR"  # Clean up the cloned repository
        exit 1
    fi
    
    # Clean up the cloned repository
    echo "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
    


    # Enable and Start Sing-box service
    echo "Enabling and starting Sing-box service..."
    if command -v systemctl &>/dev/null; then
        sudo systemctl enable --now sing-box
        sudo systemctl restart sing-box
        echo "Sing-box service started and enabled on boot."
    else
        echo "Error: systemctl not found. Unable to enable Sing-box service."
        exit 1
    fi

    # === Install `sing-box-fetch.sh` Script ===
    FETCH_SCRIPT_SOURCE="$HOME/.local/dotfiles/sing-box-fetch.sh"
    FETCH_SCRIPT_DEST="/usr/local/bin/sing-box-fetch.sh"

    if [ -f "$FETCH_SCRIPT_SOURCE" ]; then
        echo "Copying sing-box-fetch.sh to /usr/local/bin..."
        sudo cp "$FETCH_SCRIPT_SOURCE" "$FETCH_SCRIPT_DEST"
        sudo chmod +x "$FETCH_SCRIPT_DEST"
        echo "Sing-box fetch script installed successfully."
    else
        echo "Error: sing-box-fetch.sh not found in $FETCH_SCRIPT_SOURCE"
        exit 1
    fi

    # === Add to Root Crontab if Not Already Present ===
    CRON_ENTRY="* * * * * /usr/local/bin/sing-box-fetch.sh >> /var/log/sing-box-fetch.log 2>&1"
    sudo crontab -l | grep -F "$CRON_ENTRY" || (
        echo "Adding sing-box-fetch.sh to root's crontab..."
        (sudo crontab -l 2>/dev/null; echo "$CRON_ENTRY") | sudo crontab -
        echo "Crontab updated successfully."
    )
    if [ "$PUBLIC_PROXY" = true ]; then
        echo "Applying public proxy settings to sing-box-fetch.sh..."

        # Define the exact modification line
        MODIFICATION_LINE="sed -i 's#\"listen\": \"127.0.0.1\",#\"listen\": \"0.0.0.0\",#g' /etc/sing-box/config.json"

        # Check if the line already exists in the script before appending
        if ! sudo grep -Fxq "$MODIFICATION_LINE" "$FETCH_SCRIPT_DEST"; then
            echo "Appending public proxy modification to sing-box-fetch.sh..."
            echo "$MODIFICATION_LINE" | sudo tee -a "$FETCH_SCRIPT_DEST" > /dev/null
            echo "systemctl restart sing-box.service" | sudo tee -a "$FETCH_SCRIPT_DEST" > /dev/null

            enable_singbox_service
            echo "Public proxy settings applied successfully."
        else
            echo "Public proxy modification already exists in sing-box-fetch.sh, skipping."
        fi
    fi
else
    echo "Skipping Sing-box installation and proxy setup (no --with-proxy argument provided)."
fi

echo "Dotfiles installation and Fish setup complete!"




