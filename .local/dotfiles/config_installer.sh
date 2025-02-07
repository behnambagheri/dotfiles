#!/bin/bash
##Install:
#bash <(GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" git clone git@github.com:behnambagheri/dotfiles.git /tmp/dotfiles && echo /tmp/dotfiles/.local/dotfiles/config_installer.sh)
##Update:
#config pull && bash .local/dotfiles/config_installer.sh

set -e  # Exit on error

#echo "Updating system and installing Fish shell..."
#sudo apt update
#sudo apt install -y fish
#
# Check if --with-proxy argument is provided
INSTALL_PROXY=false
for arg in "$@"; do
    if [[ "$arg" == "--with-proxy" ]]; then
        INSTALL_PROXY=true
        break
    fi
done

echo "Updating system and installing the latest Fish shell..."
if [[ "$(uname -s)" == "Linux" ]]; then
    if command -v apt &>/dev/null; then
        sudo apt-add-repository ppa:fish-shell/release-3 -y
        sudo apt install -y fish curl git bat fdclone vim
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
        echo "Sing-box service started and enabled on boot."
    else
        echo "Error: systemctl not found. Unable to enable Sing-box service."
        exit 1
    fi
}



# === Install Sing-box only if --with-proxy is provided ===
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
        setup_apt_proxy  # Apply APT proxy

    elif command -v dnf &>/dev/null; then
        echo "Detected RedHat-based system. Installing Sing-box..."
        sudo dnf -y install dnf-plugins-core
        sudo dnf config-manager --add-repo https://sing-box.app/sing-box.repo
        sudo dnf install -y sing-box
        setup_dnf_yum_proxy  # Apply DNF/YUM proxy

    else
        echo "Unsupported package manager. Skipping Sing-box installation."
    fi

    # Copy configuration file for Sing-box
    CONFIG_SOURCE="$HOME/.local/dotfiles/singbox.json"
    CONFIG_DEST="/etc/sing-box/config.json"

    if [ -f "$CONFIG_SOURCE" ]; then
        echo "Copying Sing-box configuration file..."
        sudo mkdir -p /etc/sing-box
        sudo cp "$CONFIG_SOURCE" "$CONFIG_DEST"
        echo "Configuration file copied successfully."
    else
        echo "Error: Configuration file not found at $CONFIG_SOURCE"
        exit 1
    fi

    # Enable and Start Sing-box service
    enable_singbox_service

else
    echo "Skipping Sing-box installation and proxy setup (no --with-proxy argument provided)."
fi


echo "Dotfiles installation and Fish setup complete!"




