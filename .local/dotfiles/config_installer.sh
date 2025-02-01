#!/bin/bash
##Install:
# bash <(git clone  git@github.com:behnambagheri/dotfiles.git /tmp/dotfiles && echo /tmp/dotfiles/.local/dotfiles/config_installer.sh)
##Update:
#config pull && bash .local/dotfiles/config_installer.sh

set -e  # Exit on error

#echo "Updating system and installing Fish shell..."
#sudo apt update
#sudo apt install -y fish
#


echo "Updating system and installing the latest Fish shell..."
if [[ "$(uname -s)" == "Linux" ]]; then
    if command -v apt &>/dev/null; then
        sudo apt-add-repository ppa:fish-shell/release-3 -y
        sudo apt install -y fish curl git bat fdclone vim
    elif command -v dnf &>/dev/null; then
        sudo dnf install -y fish curl git bat fdclone vim
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
    git clone --bare git@github.com:behnambagheri/dotfiles.git "$HOME/.dotfiles"
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


echo "Dotfiles installation and Fish setup complete!"
