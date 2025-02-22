#!/bin/bash
#shellcheck disable=SC2034
##Install:
#bash <(GIT_SSH_COMMAND="ssh -o StrictHostKeyChecking=no" git clone git@github.com:behnambagheri/dotfiles.git /tmp/dotfiles && echo /tmp/dotfiles/.local/dotfiles/config_installer.sh)
##Update:
#config-update
##Fix:
# rm -rf .dotfiles /tmp/lab /tmp/dotftiles && git clone --bare https://github.com/behnambagheri/dotfiles.git "$HOME/.dotfiles" && git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME config --local status.showUntrackedFiles no && git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME reset --hard

#set -e  # Exit on error


INSTALL_PROXY=false
PUBLIC_PROXY=false



# Define proxy settings
PROXY="socks5h://127.0.0.1:7890"


# Define color codes
BLACK="\033[30m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"
DEFAULT_COLOR="\033[0m"

# List of required packages
PACKAGES=(
    fish curl git bat fd-find vim glances wget dnsutils bind9-host
    nmap iputils-ping rsync netcat-traditional gcc build-essential
    net-tools iproute2 unzip bind9-utils prometheus-node-exporter
    ncdu nethogs jq python3-full python3-pip python3-venv ripgrep pipx
    ninja-build gettext cmake unzip
)


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


log() {
  local msg="$1"
  local color="${2:-$DEFAULT_COLOR}"
  local include_timestamp="${3:-false}"

  if [[ "$include_timestamp" == "true" ]]; then
    local timestamp
    timestamp=$(date "+%F %T")
    msg="$timestamp - $msg"
  fi

  echo -e "${color}${msg}${DEFAULT_COLOR}"
#  logger "$msg"
}

clone_projects(){
  local PROJ DIR
  PROJ="$1"
  DIR="$2"

  # Clone the repository
  log "Cloning repository from $PROJ into $DIR..."
  if [[ -d "$DIR" ]]; then
    git -C "$DIR" pull
  else
    if git clone "$PROJ" "$DIR" > /dev/null; then
      log "Git clone success." "$GREEN"
    else
      log "Error: Git clone failed." "$RED"
      exit 1
    fi
  fi
}

# Function to check if a package is installed
is_installed() {
    dpkg -l "$1" &>/dev/null
}



install_with_package_manager(){
  local NEEDRESTART_MODE DEBIAN_FRONTEND TO_INSTALL pkg
  log "Updating system and installing the latest Fish shell..." "$CYAN"

  # Ensure non-interactive mode
  export NEEDRESTART_MODE=a
  export DEBIAN_FRONTEND=noninteractive

  if [ "$INSTALL_PROXY" = true ]; then
    log "Detected Debian-based system. Installing Sing-box..." "$MAGENTA"
    if ! [[ -d "/etc/apt/keyrings" ]]; then
      sudo mkdir -p /etc/apt/keyrings
    fi
    sudo curl -fsSL https://sing-box.app/gpg.key -o /etc/apt/keyrings/sagernet.asc
    sudo chmod a+r /etc/apt/keyrings/sagernet.asc
    if ! [[ -f "/etc/apt/sources.list.d/sagernet.list" ]]; then
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/sagernet.asc] https://deb.sagernet.org/ * *" | \
        sudo tee /etc/apt/sources.list.d/sagernet.list > /dev/null
    fi
  fi

  if [[ "$(uname -s)" == "Linux" ]]; then
    if command -v apt &>/dev/null; then

    # Check if Fish PPA is already added
    if grep -Rq "fish-shell/release-3" /etc/apt/sources.list.d/; then
      log "PPA already added. Skipping..." "$YELLOW"
    else
      log "Adding Fish Shell repository..." "$CYAN"
      sudo add-apt-repository -y ppa:fish-shell/release-3
    fi
      log "Updating package list..." "$CYAN"
      sudo apt update -y > /dev/null || log "Error occurred during apt update" "$RED"
      log "Installing required packages..." "$CYAN"

      # Filter out already installed packages
      TO_INSTALL=()
      for pkg in "${PACKAGES[@]}"; do
          if ! is_installed "$pkg"; then
              TO_INSTALL+=("$pkg")
          fi
      done


      # If there are packages to install, install them
      if [ ${#TO_INSTALL[@]} -gt 0 ]; then
          sudo apt install -y --no-install-recommends "${TO_INSTALL[@]}" > /dev/null || log "Error occurred during package installation" "$RED"
      else
          echo "All required packages are already installed. Skipping installation."
      fi

      if [ "$INSTALL_PROXY" = true ]; then
        log "Installing Sing-box..." "$MAGENTA"
          # Ensure non-interactive mode
        export NEEDRESTART_MODE=a
        export DEBIAN_FRONTEND=noninteractive
        if ! is_installed "sing-box"; then
          sudo apt install -y sing-box
        fi
      fi
    fi
  else
    log "Unsupported operating system." "$RED"
    exit 1
  fi
}


install_nodejs(){
  local node_version npm_version NEEDRESTART_MODE DEBIAN_FRONTEND
    # Install Node.js using NodeSource
  log "Installing Node.js..." "$CYAN"
  curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    # Ensure non-interactive mode
  export NEEDRESTART_MODE=a
  export DEBIAN_FRONTEND=noninteractive
  sudo apt install -y nodejs

  # Verify installation
  log "Verifying Node.js installation..." "$YELLOW"
  node_version=$(node -v)
  npm_version=$(npm -v)

  if [[ -n "$node_version" && -n "$npm_version" ]]; then
    log "Node.js installed successfully!" "$GREEN"
    log "Node.js version: $node_version" "$MAGENTA"
    log "NPM version: $npm_version" "$MAGENTA"
  else
    log "Node.js installation failed." "$RED"
    exit 1
  fi

}
install_fzf(){

  # Install fzf (Fuzzy Finder)
  log "Installing fzf..." "$CYAN"
  if [ ! -d "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
  else
    log "fzf already exists, skipping clone." "$YELLOW"
  fi

  ~/.fzf/install --all

}

install_omf(){
    # Install Oh My Fish (OMF) if not already installed
  if [ ! -d "$HOME/.local/share/omf" ]; then
      log "Installing Oh My Fish..." "$CYAN"
      curl -L https://get.oh-my.fish | fish
  fi

}

install_fisher(){
    # Install Fisher (if not already installed)
  if ! fish -c "functions -q fisher"; then
      log "Installing Fisher..." "$CYAN"
  #    curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
      fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
  fi

}

install_lambda_theme(){
  # Install OMF theme
  fish -c 'omf install lambda'
}

configure_done_notify(){
  local DONE_NOTIFY_PATH
  log "Adding done_notify..." "$CYAN"

  # Corrected path (removed extra 'home')
  DONE_NOTIFY_PATH="$TEMP_DIR/home/bea/scripts/bea/done_notify.fish"

  # Ensure the script exists before sourcing
  if [ -f "$DONE_NOTIFY_PATH" ]; then
      log "Sourcing done_notify.fish..." "$CYAN"
      fish -c "source $DONE_NOTIFY_PATH"
      fish -c "fisher install franciscolourenco/done"

      fish -c "source $DONE_NOTIFY_PATH"

      cp "$DONE_NOTIFY_PATH" "$HOME/.local/dotfiles/"

      fish -c "source $HOME/.local/dotfiles/done_notify.fish"
  else
      log "Error: done_notify.fish not found at $DONE_NOTIFY_PATH" "$RED"
      exit 1
  fi
}

install_fish_plugins(){

  # Install Fisher plugins
  log "Installing Fisher plugins..." "$CYAN"

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
  fish -c "fisher install nickeb96/puffer-fish"
  fish -c "fisher install acomagu/fish-async-prompt@a89bf4216b65170e4c3d403e7cbf24ce34b134e6"
  fish -c "fisher install franciscolourenco/done"
  configure_done_notify

  # Install Docker plugins only if Docker is installed
  if command -v docker &>/dev/null; then
      log "Docker detected! Installing Docker plugins..." "$MAGENTA"
      fish -c "fisher install asim-tahir/docker.fish"
      fish -c "fisher install brgmnn/fish-docker-compose"
      fish -c "fisher install asim-tahir/docker-compose.fish"
  else
      log "Docker not found. Skipping Docker plugins." "$YELLOW"
  fi




  # Install Kubernetes plugin only if kubectl is installed
  if command -v kubectl &>/dev/null; then
      log "kubectl detected! Installing Kubernetes plugin..." "$MAGENTA"
      fish -c "fisher install blackjid/plugin-kubectl"
  else
      log "kubectl not found. Skipping Kubernetes plugin." "$YELLOW"
  fi

  # Install Homebrew completion plugin only on macOS
  if [[ "$(uname -s)" == "Darwin" ]]; then
      log "macOS detected! Installing Homebrew completions..." "$MAGENTA"
      fish -c "fisher install laughedelic/brew-completions"
  else
      log "Not macOS. Skipping Homebrew completions." "$YELLOW"
  fi

}

install_iterm2_shell_integrations(){
  log "Install iterm2 shell_integration" "$CYAN"
  curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash
  # source $HOME/.iterm2_shell_integration.fish
}

install_virtual_fish(){
  # Ensure pipx path is set
  pipx ensurepath

  # Install VirtualFish
  pipx install virtualfish
  pipx ensurepath
  export PATH="$HOME/.local/bin:$PATH"

  # Configure VirtualFish
  vf install compat_aliases auto_activation

  log "VirtualFish installation completed successfully." "$GREEN"

}

install_nvim(){
  local  INSTALL_DIR
  log "Installing neovim" "$CYAN"


  log "Checking if Neovim is already installed..." "$MAGENTA"
  if command -v nvim &>/dev/null; then
      log "Neovim is already installed! Skipping installation." "$YELLOW"
      nvim --version

  else

    log "Installing Neovim..." "$CYAN"

    # Define the installation directory
    INSTALL_DIR="$HOME/neovim-build"


    # Clone the Neovim repository
    log "Cloning Neovim repository..." "$CYAN"
    git clone https://github.com/neovim/neovim.git "$INSTALL_DIR"

    # Navigate to the Neovim directory
    cd "$INSTALL_DIR" || exit

    # Checkout the stable version
    log "Checking out the stable version of Neovim..." "$BLUE"
    git checkout stable

    # Build Neovim
    log "Building Neovim..." "$BLUE"
    make CMAKE_BUILD_TYPE=RelWithDebInfo

    # Install Neovim
    log "Installing Neovim..." "$CYAN"
    sudo make install

    # Verify installation
    log "Verifying Neovim installation..." "$MAGENTA"
    nvim --version

    # Cleanup: Remove the build directory
    log "Cleaning up..." "$BLUE"
    cd "$HOME" || exit
    rm -rf "$INSTALL_DIR"



    log "Neovim installation completed successfully!" "$GREEN"


  fi


}

install_packages(){
  install_with_package_manager
  install_nodejs
  install_fzf
  install_omf
  install_fisher
  install_lambda_theme
  install_fish_plugins
  install_iterm2_shell_integrations
  install_virtual_fish
  install_nvim


}

configure_fish(){

  # Check if Fish shell is installed before proceeding
  if command -v fish &>/dev/null; then
    log "Fish installed successfully: $(fish --version)" "$GREEN"
  else
    log "Error: Fish installation failed!" "$RED"
    exit 1
  fi

  # Change the default shell to Fish (only if necessary)
  if [[ "$SHELL" != "$(which fish)" ]]; then
      log "Setting Fish as default shell..." "$BLUE"
      chsh -s "$(which fish)"
  fi

  # Configure Fish
  log "Configuring Fish..." "$MAGENTA"
  fish -c 'set -U fish_greeting ""'




}

configure_vim(){

  # Install Vim-Plug if not installed
  if [ ! -f "$HOME/.vim/autoload/plug.vim" ]; then
      log "Installing Vim-Plug..." "$CYAN"
      curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
          https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  fi

  # Install Vim plugins automatically
  log "Installing Vim plugins with PlugInstall..." "$CYAN"
  vim +PlugInstall +qall
  #vim -es -c "CocInstall coc-pyright" -c "q"

}

configure_nvim(){
  local VENV_PATH
    sudo chown -R "$(id -u)":"$(id -g)" "$HOME/.local/share/nvim"


    # Set the virtual environment path
    VENV_PATH="$HOME/.venvs/neovim"

    # Create the virtual environment if it doesn't exist
    if [ ! -d "$VENV_PATH" ]; then
        log "Creating Python virtual environment for Neovim..." "$CYAN"
        python3 -m venv "$VENV_PATH"
    else
        log "Virtual environment already exists at $VENV_PATH." "$YELLOW"
    fi

    # Activate the virtual environment
    log "Activating virtual environment..." "$BLUE"
    # shellcheck source=./activate
    source "$VENV_PATH/bin/activate"

    # Install the Neovim Python package
    log "Installing Neovim Python package..." "$CYAN"
    "$HOME"/.venvs/neovim/bin/pip install --upgrade pip
    "$HOME"/.venvs/neovim/bin/pip install neovim
    "$HOME"/.venvs/neovim/bin/pip install 'python-lsp-server[all]'

    # Deactivate the virtual environment
    deactivate

    log "Setup complete! Make sure to add this to your init.vim:" "$GREEN"
    if [[ -d "$HOME/.npm" ]]; then
      sudo chown -R "$(id -u)":"$(id -g)" "$HOME/.npm"
    fi
    npm install -g neovim --prefix="$HOME/.npm-global"
    npm install -g bash-language-server --prefix="$HOME/.npm-global"
    sudo npm install -g neovim
    sudo npm install -g bash-language-server
    export PATH="$HOME/.npm-global/bin:$PATH"
    # shellcheck source=/Users/behnam/.bashrc
    source ~/.bashrc

    log "Installing Vim-Plug for Neovim..." "$CYAN"

    # Install Vim-Plug if not already installed
    curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    log "Installing NeoVim plugins..." "$CYAN"
    sudo chown -R "$(id -u)":"$(id -g)" "$HOME/.local/state/nvim/"

    nvim --headless +PlugInstall +qall

    # Ensure Neovim and coc.nvim are installed before running CocInstall
    log "Installing coc.nvim extensions..." "$CYAN"
    nvim --headless -c 'CocInstall -sync coc-json coc-html coc-css coc-yaml coc-sh' -c 'qall'

    log "Neovim setup completed successfully!" "$GREEN"


}


# APT Proxy Setup (For Debian-based systems)
setup_apt_proxy() {
    log "Configuring APT proxy..." "$BLUE"
    sudo bash -c "cat > /etc/apt/apt.conf.d/01proxy" <<EOF
Acquire::http::Proxy  "$PROXY";
Acquire::https::Proxy "$PROXY";
EOF
    log "APT proxy configured successfully!" "$GREEN"
}

# Enable and Start Sing-box Service
enable_singbox_service() {
    log "Enabling and starting Sing-box service..." "$BLUE"
    if command -v systemctl &>/dev/null; then
        sudo systemctl enable --now sing-box
        sudo systemctl restart sing-box

        log "Sing-box service started and enabled on boot." "$BLUE"
    else
        log "Error: systemctl not found. Unable to enable Sing-box service." "$RED"
        exit 1
    fi
}

configure_singbox(){
  local CONFIG_DEST CONFIG_SOURCE FETCH_SCRIPT_DEST FETCH_SCRIPT_SOURCE CRON_ENTRY MODIFICATION_LINE MODIFICATION_LINE2

  # Install Sing-box and configure proxy if `--with-proxy` is provided
  if [ "$INSTALL_PROXY" = true ]; then


      # Define source and destination paths for configuration
      CONFIG_SOURCE="$TEMP_DIR/var/www/subscription/sbox/routers.json"
      CONFIG_DEST="/etc/sing-box/config.json"

      # Check if the configuration file exists
      if [ -f "$CONFIG_SOURCE" ]; then
          log "Copying Sing-box configuration file..." "$MAGENTA"
          sudo mkdir -p /etc/sing-box
          sudo cp "$CONFIG_SOURCE" "$CONFIG_DEST"
          log "Configuration file copied successfully." "$GREEN"
      else
          log "Error: Configuration file not found at $CONFIG_SOURCE" "$RED"
          rm -rf "$TEMP_DIR"  # Clean up the cloned repository
          exit 1
      fi



      # Enable and Start Sing-box service
      log "Enabling and starting Sing-box service..." "$MAGENTA"
      if command -v systemctl &>/dev/null; then
          sudo systemctl enable --now sing-box
          sudo systemctl restart sing-box
          log "Sing-box service started and enabled on boot." "$GREEN"
      else
          log "Error: systemctl not found. Unable to enable Sing-box service." "$RED"
          exit 1
      fi

      # === Install `sing-box-fetch.sh` Script ===
      FETCH_SCRIPT_SOURCE="$TEMP_DIR/home/bea/scripts/bea/sing-box-fetch.sh"

      FETCH_SCRIPT_DEST="/usr/local/bin/sing-box-fetch.sh"

      if [ -f "$FETCH_SCRIPT_SOURCE" ]; then
          log "Copying sing-box-fetch.sh to /usr/local/bin..." "$MAGENTA"
          sudo cp "$FETCH_SCRIPT_SOURCE" "$FETCH_SCRIPT_DEST"
          sudo chmod +x "$FETCH_SCRIPT_DEST"
          log "Sing-box fetch script installed successfully." "$GREEN"
      else
          log "Error: sing-box-fetch.sh not found in $FETCH_SCRIPT_SOURCE" "$GREEN"
          exit 1
      fi

      # === Add to Root Crontab if Not Already Present ===
      CRON_ENTRY="* * * * * /usr/local/bin/sing-box-fetch.sh >> /var/log/sing-box-fetch.log 2>&1"
      sudo crontab -l | grep -F "$CRON_ENTRY" || (
          log "Adding sing-box-fetch.sh to root's crontab..." "$BLUE"
          (sudo crontab -l 2>/dev/null; echo "$CRON_ENTRY") | sudo crontab -
          log "Crontab updated successfully." "$GREEN"
      )



      if command -v apt &>/dev/null; then
          setup_apt_proxy

      else
          log "Unsupported package manager. Skipping Sing-box installation." "$RED"
      fi



      if [ "$PUBLIC_PROXY" = true ]; then
          log "Applying public proxy settings to sing-box-fetch.sh..." "$MAGENTA"

          # Define the exact modification line
          MODIFICATION_LINE="sed -i 's#\"listen\": \"127.0.0.1\",#\"listen\": \"0.0.0.0\",#g' /etc/sing-box/config.json"
          MODIFICATION_LINE2="sed -i 's#\"external_controller\": \"127.0.0.1:9090\"#\"external_controller\": \"0.0.0.0:9090\"#g' /etc/sing-box/config.json"

          # Check if the line already exists in the script before appending
          if ! sudo grep -Fxq "$MODIFICATION_LINE" "$FETCH_SCRIPT_DEST"; then
              log "Appending public proxy modification to sing-box-fetch.sh..." "$MAGENTA"
              echo "$MODIFICATION_LINE" | sudo tee -a "$FETCH_SCRIPT_DEST" > /dev/null
              echo "$MODIFICATION_LINE2" | sudo tee -a "$FETCH_SCRIPT_DEST" > /dev/null

              enable_singbox_service
              log "Public proxy settings applied successfully." "$GREEN"
          else
              log "Public proxy modification already exists in sing-box-fetch.sh, skipping." "$YELLOW"
          fi
      fi
  else
      log "Skipping Sing-box installation and proxy setup (no --with-proxy argument provided)." "$YELLOW"
  fi
}

initialize_config(){

  # Clone dotfiles repository if it doesn't exist
  if [ ! -d "$HOME/.dotfiles" ]; then
      log "Cloning dotfiles repository..." "$CYAN"
      git clone --bare git@github.com:behnambagheri/dotfiles.git "$HOME/.dotfiles"
  else
      log "Dotfiles repository already exists, skipping clone." "$YELLOW"
  fi

  # Configure Git to ignore untracked files
  git --git-dir="$HOME"/.dotfiles/ --work-tree="$HOME" config --local status.showUntrackedFiles no

  # Hard reset dotfiles to repo state
  git --git-dir="$HOME"/.dotfiles/ --work-tree="$HOME" reset --hard
  git --git-dir="$HOME"/.dotfiles/ --work-tree="$HOME" config pull.rebase false

  # Remove default Lambda theme prompt (if it exists)
  rm -f "$HOME/.local/share/omf/themes/lambda/functions/fish_right_prompt.fish"
  rm -f "$HOME/.local/share/omf/themes/lambda/functions/fish_prompt.fish"


  # Ensure the target directory exists before symlinking
  mkdir -p "$HOME/.local/share/omf/themes/lambda/functions"
  ln -sf "$HOME/.local/dotfiles/fish_prompt.fish" "$HOME/.local/share/omf/themes/lambda/functions/fish_prompt.fish"
}

cleanup(){
  # Clean up the cloned repository
  log "Cleaning up temporary files..." "$BLUE"
  rm -rf "$TEMP_DIR"
}

source_varibales(){
  log "source variables..." "$BLUE"
  fish -c "source $HOME/.local/dotfiles/variables.fish"
}








clone_projects "git@github.com:behnambagheri/lab.git" "/tmp/lab"
install_packages
configure_fish
configure_vim
configure_nvim
configure_singbox
initialize_config
source_varibales
cleanup

log "Dotfiles installation and Fish setup complete!" "$GREEN"
