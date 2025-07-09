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
    ninja-build gettext cmake unzip software-properties-common
    ripgrep chafa build-essential cmake libfuse2 unrar
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
clone_projects() {
  local PROJ DIR
  PROJ="$1"
  DIR="$2"

  # Clone the repository
  log "Cloning repository from $BLUE $PROJ into $GREEN $DIR..."

  if [[ -d "$DIR" ]]; then
    # Pull latest changes, but suppress output unless an error occurs
    git -C "$DIR" pull > /dev/null 2>&1 || log "Error: Git pull failed in $DIR" "$RED"
  else
    # Clone the repository, but suppress output unless an error occurs
    if git clone "$PROJ" "$DIR" > /dev/null 2>&1; then
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
    if grep -Rq "fish-shell/release-4" /etc/apt/sources.list.d/; then
      log "PPA already added. Skipping..." "$YELLOW"
    else
      log "Adding Fish Shell repository..." "$CYAN"
      sudo add-apt-repository -y ppa:fish-shell/release-4
    fi
      log "Updating package list..." "$CYAN"
      sudo apt-get update -y > /dev/null || log "Error occurred during apt update" "$RED"
      log "Installing required packages..." "$CYAN"

      # Filter out already installed packages
      TO_INSTALL=()
      for pkg in "${PACKAGES[@]}"; do
          if ! is_installed "$pkg"; then
              TO_INSTALL+=("$pkg")
          fi
      done
      if ! [[ -L "$HOME/.local/bin/fd" ]] && [[ -e "$(which fdfind)" ]]; then
        ln -s "$(which fdfind)" ~/.local/bin/fd
      fi

      # If there are packages to install, install them
      if [ ${#TO_INSTALL[@]} -gt 0 ]; then
          sudo apt-get install -y --no-install-recommends "${TO_INSTALL[@]}" > /dev/null || log "Error occurred during package installation" "$RED"
      else
          log "All required packages are already installed. Skipping installation." "$GREEN"
      fi

      if [ "$INSTALL_PROXY" = true ]; then
        log "Installing Sing-box..." "$MAGENTA"
          # Ensure non-interactive mode
        export NEEDRESTART_MODE=a
       export DEBIAN_FRONTEND=noninteractive
        if ! is_installed "sing-box"; then
          sudo apt-get install -y sing-box
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
  if ! is_installed "nodejs"; then

    log "Installing Node.js..." "$CYAN"
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
      # Ensure non-interactive mode
     export NEEDRESTART_MODE=a
    export DEBIAN_FRONTEND=noninteractive
    sudo apt-get install -y nodejs

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
  else
    log "Node.js is already installed. Skipping installation." "$YELLOW"
  fi

}

install_fzf() {
  local REQUIRED_VERSION CURRENT_VERSION temp_dir
  REQUIRED_VERSION="0.63.0"
  CURRENT_VERSION=$(command -v fzf >/dev/null && fzf --version | awk '{print $1}' || echo "0")

  version_lt() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" != "$2" ]
  }

  if ! command -v fzf &>/dev/null; then
    log "fzf not found, installing..." "$CYAN"
  elif version_lt "$CURRENT_VERSION" "$REQUIRED_VERSION"; then
    log "fzf outdated ($CURRENT_VERSION), upgrading..." "$MAGENTA"
  else
    log "fzf already installed (version $CURRENT_VERSION)." "$MAGENTA"
    return
  fi

  temp_dir=$(mktemp -d)
  cd "$temp_dir" >/dev/null || exit 1
  wget -q https://github.com/junegunn/fzf/releases/download/v$REQUIRED_VERSION/fzf-${REQUIRED_VERSION}-linux_amd64.tar.gz
  tar xzf fzf-${REQUIRED_VERSION}-linux_amd64.tar.gz >/dev/null
  sudo mv fzf /usr/local/bin/ >/dev/null 2>&1
  cd - >/dev/null || exit
  rm -rf "$temp_dir" "$HOME/.fzf" >/dev/null 2>&1
}

install_omf(){
  # Install Oh My Fish (OMF) if not already installed
  if [ ! -d "$HOME/.local/share/omf" ]; then
      log "Installing Oh My Fish..." "$CYAN"
#      curl -L https://get.oh-my.fish | fish
      curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish
  else
    log "omf already exists, skipping clone." "$YELLOW"
  fi

}
install_fisher(){
  # Install Fisher (if not already installed)
  if ! fish -c "functions -q fisher"; then
    log "Installing Fisher..." "$CYAN"
    fish -c 'curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher'
  else
    log "fisher already exists, skipping clone." "$YELLOW"
  fi
}
install_lambda_theme(){
  if fish -c 'omf theme | head -2 | grep lambda > /dev/null'; then
    log "lambda theme already exists, skipping clone." "$YELLOW"
  else
    # Install OMF theme
    fish -c 'omf install lambda'
  fi
}

configure_bat(){
  mkdir -p ~/.local/bin
  if ! [[ -L "$HOME/.local/bin/bat" ]]; then
    ln -s /usr/bin/batcat ~/.local/bin/bat
  fi
  echo "export PATH=\$HOME/.local/bin:\$PATH" >> ~/.bashrc
  # shellcheck source=/Users/behnam/.bashrc
  source ~/.bashrc
}
install_lsd() {
  local LSD_DEB LSD_URL LSD_VERSION
  # Remove a snap version if it exists
  if [[ -e "/snap/bin/lsd" ]]; then
    log "Removing snap version of lsd..." "$YELLOW"
    sudo snap remove lsd
  fi

  # Install lsd only if it's not already installed
  if command -v lsd &>/dev/null; then
    log "lsd already installed." "$MAGENTA"
  else
    log "Installing lsd..." "$CYAN"
    LSD_VERSION="1.1.5"
    LSD_DEB="lsd_${LSD_VERSION}_$(dpkg --print-architecture).deb"
    LSD_URL="https://github.com/lsd-rs/lsd/releases/download/v${LSD_VERSION}/${LSD_DEB}"

    curl -sL "$LSD_URL" -o "$LSD_DEB"
    if sudo dpkg -i "$LSD_DEB"; then
      log "lsd installation completed successfully." "$GREEN"
    else
      log "Fixing broken dependencies..." "$YELLOW"
      sudo apt --fix-broken install -y
    fi

    # Cleanup
    rm -f "$LSD_DEB"

    # Final check
    if command -v lsd &>/dev/null; then
      log "lsd is now installed." "$GREEN"
    else
      log "lsd installation failed." "$RED"
    fi
  fi
}
configure_done_notify() {
    local DONE_NOTIFY_PATH="/tmp/lab/home/bea/scripts/bea/done_notify.fish"

    log "Adding done_notify..." "$CYAN"

    # Ensure fish shell is installed
    if ! command -v fish &> /dev/null; then
        log "Error: fish shell is not installed. Please install fish first." "$RED"
        exit 1
    fi

    # Ensure the script exists before sourcing
    if [ -f "$DONE_NOTIFY_PATH" ]; then
        log "Sourcing done_notify.fish..." "$CYAN"

        fish -c "source $DONE_NOTIFY_PATH"

        # Ensure fisher is installed
        if ! fish -c "functions -q fisher"; then
            log "Installing Fisher package manager for fish..." "$YELLOW"
            fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher"
        fi

        # Install `done` plugin if not already installed
        if ! fish -c "functions -q done"; then
            log "Installing done plugin..." "$CYAN"
            fish -c "fisher install franciscolourenco/done"
        else
            log "done plugin already installed." "$YELLOW"
        fi

        # Copy to local dotfiles for persistence
        mkdir -p "$HOME/.local/dotfiles/"
        cp "$DONE_NOTIFY_PATH" "$HOME/.local/dotfiles/"

        # Source from local dotfiles
        fish -c "source $HOME/.local/dotfiles/done_notify.fish"

        log "done_notify setup completed successfully!" "$GREEN"
    else
        log "Error: done_notify.fish not found at $DONE_NOTIFY_PATH" "$RED"
        exit 1
    fi
}
install_fish_plugins() {
  local PLUGINS plugin DOCKER_PLUGINS
  # Ensure Fisher is installed before proceeding
  if ! fish -c "fisher --version" &>/dev/null; then
    log "Fisher not found. Installing Fisher..." "$CYAN"
    fish -c "curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher" > /dev/null 2>&1 || log "Error installing Fisher!" "$RED"
  fi

  log "Installing Fisher plugins..." "$CYAN"

  # Define plugins list
  PLUGINS=(
    "jorgebucaran/fisher"
    "jhillyerd/plugin-git"
    "jethrokuan/z"
    "patrickf3139/colored-man-pages"
    "markcial/upto"
    "jorgebucaran/autopair.fish"
    "laughedelic/pisces"
    "PatrickF1/fzf.fish"
    "nickeb96/puffer-fish"
    "acomagu/fish-async-prompt@a89bf4216b65170e4c3d403e7cbf24ce34b134e6"
    "franciscolourenco/done"
    "0rax/fish-bd"
  )

  # Check and install missing plugins
  for plugin in "${PLUGINS[@]}"; do
    if ! fish -c "fisher list | grep -q \"$plugin\""; then
      fish -c "fisher install $plugin" > /dev/null 2>&1 || log "Error installing $plugin" "$RED"
    else
      log "Plugin $plugin is already installed. Skipping..." "$YELLOW"
    fi
  done

  configure_done_notify

  # Install Docker plugins only if Docker is installed
  if command -v docker &>/dev/null; then
    log "Docker detected! Installing Docker plugins..." "$MAGENTA"
    DOCKER_PLUGINS=(
      "asim-tahir/docker.fish"
      "brgmnn/fish-docker-compose"
      "asim-tahir/docker-compose.fish"
    )
    for plugin in "${DOCKER_PLUGINS[@]}"; do
      if ! fish -c "fisher list | grep -q \"$plugin\""; then
        fish -c "fisher install $plugin" > /dev/null 2>&1 || log "Error installing $plugin" "$RED"
      else
        log "Plugin $plugin is already installed. Skipping..." "$YELLOW"
      fi
    done
  else
    log "Docker not found. Skipping Docker plugins." "$YELLOW"
  fi

  # Install Kubernetes plugin only if kubectl is installed
  if command -v kubectl &>/dev/null; then
    log "kubectl detected! Installing Kubernetes plugin..." "$MAGENTA"
    if ! fish -c "fisher list | grep -q 'blackjid/plugin-kubectl'"; then
      fish -c "fisher install blackjid/plugin-kubectl" > /dev/null 2>&1 || log "Error installing Kubernetes plugin" "$RED"
    else
      log "Kubernetes plugin is already installed. Skipping..." "$YELLOW"
    fi
  else
    log "kubectl not found. Skipping Kubernetes plugin." "$YELLOW"
  fi

  # Install Homebrew completion plugin only on macOS
  if [[ "$(uname -s)" == "Darwin" ]]; then
    log "macOS detected! Installing Homebrew completions..." "$MAGENTA"
    if ! fish -c "fisher list | grep -q 'laughedelic/brew-completions'"; then
      fish -c "fisher install laughedelic/brew-completions" > /dev/null 2>&1 || log "Error installing Homebrew completions" "$RED"
    else
      log "Homebrew completions plugin is already installed. Skipping..." "$YELLOW"
    fi
  else
    log "Not macOS. Skipping Homebrew completions." "$YELLOW"
  fi
}
install_iterm2_shell_integrations() {
  local iterm_file="$HOME/.iterm2_shell_integration.fish"

  # Check if the shell integration script is already present
  if [[ -f "$iterm_file" ]]; then
    log "iTerm2 shell integration is already installed. Skipping installation." "$YELLOW"
    return 0
  fi

  # Install iTerm2 shell integration
  log "Installing iTerm2 shell integration..." "$CYAN"
  if curl -L https://iterm2.com/shell_integration/install_shell_integration_and_utilities.sh | bash > /dev/null 2>&1; then
    log "iTerm2 shell integration installed successfully." "$GREEN"
  else
    log "Error: iTerm2 shell integration installation failed." "$RED"
    exit 1
  fi
}
install_virtual_fish() {
  # Ensure pipx is available
  if ! command -v pipx &>/dev/null; then
      log "Error: pipx is not installed. Please install it first." "$RED"
      return 1
  fi

  # Check if VirtualFish is already installed
  if pipx list | grep -q "virtualfish"; then
      log "✅ VirtualFish is already installed. No changes needed." "$GREEN"
  else
      log "⚠️ VirtualFish not found. Installing now..." "$MAGENTA"

      # Ensure pipx path is set
      pipx ensurepath

      # Install VirtualFish
      pipx install virtualfish
      pipx ensurepath

      # Export PATH to include pipx binaries
      export PATH="$HOME/.local/bin:$PATH"

      # Configure VirtualFish with plugins
      vf install compat_aliases auto_activation

      log "✅ VirtualFish installation completed successfully." "$GREEN"
  fi
}
install_nvim(){
  local INSTALL_DIR LOG_FILE

  LOG_FILE="/tmp/nvim_install.log"

#  if ! is_installed "nvim"; then
  if ! command -v nvim &>/dev/null; then
    log "🛠️ Installing Neovim..." "$CYAN"

    # Define the installation directory
    INSTALL_DIR="$HOME/neovim-build"

    # Clone the Neovim repository
    log "📥 Cloning Neovim repository..." "$CYAN"
    clone_projects "https://github.com/neovim/neovim.git" "$INSTALL_DIR" &> "$LOG_FILE"

    # Navigate to the Neovim directory
    cd "$INSTALL_DIR" || exit

    # Checkout the stable version
    log "🔄 Checking out the stable version of Neovim..." "$BLUE"
    git checkout stable &>> "$LOG_FILE"

    # Build Neovim with limited output
    log "🔧 Building Neovim (this may take some time)..." "$BLUE"
    make CMAKE_BUILD_TYPE=RelWithDebInfo -j"$(nproc)" &>> "$LOG_FILE"

    # Install Neovim
    log "📦 Installing Neovim..." "$CYAN"
#    sudo make install &>> "$LOG_FILE"
    sudo make install 2>&1 | sudo tee -a "$LOG_FILE"  > /dev/null 2>&1 /dev/null
    # Verify installation
    if command -v nvim &>/dev/null; then

      log "✅ Neovim installed successfully!" "$GREEN"
    else
      log "❌ Installation failed! Check the log: $LOG_FILE" "$RED"
      return 1
    fi

    # Cleanup
    log "🧹 Cleaning up..." "$BLUE"
    cd "$HOME" || exit
    rm -rf "$INSTALL_DIR"

  else
    log "⚠️ Neovim is already installed! Skipping installation." "$YELLOW"
  fi
}
install_helix(){
    if ! command -v hx &>/dev/null; then
      log "🛠️ Installing Helix..." "$CYAN"
      curl -s -LO https://github.com/helix-editor/helix/releases/download/25.01.1/helix-25.01.1-x86_64.AppImage
      chmod +x helix-25.01.1-x86_64.AppImage
      sudo mv helix-25.01.1-x86_64.AppImage /usr/local/bin/hx
      log "Helix Version: $(hx --version)" "$BLUE"

      if command -v hx &>/dev/null; then

        log "✅ Helix installed successfully!" "$GREEN"
      else
        log "❌ Installation failed!" "$RED"
        return 1
      fi
    else
      log "⚠️ Helix is already installed! Skipping installation." "$YELLOW"
    fi
}
install_packages(){
  install_with_package_manager
#  install_nodejs
  install_fzf
  install_lsd
  install_omf
  install_fisher
  install_lambda_theme
  install_fish_plugins
#  install_iterm2_shell_integrations
  install_virtual_fish
  install_helix
#  install_nvim


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
# shellcheck disable=SC1094
configure_nvim() {
    set -e  # Exit on error

    local VENV_PATH="$HOME/.venvs/neovim"
    local NPM_GLOBAL_PATH="$HOME/.npm-global"

    log "Setting correct permissions for Neovim directories..." "$CYAN"
    if [[ -d "$HOME/.local/share/nvim" ]]; then 
    sudo chown -R "$(id -u)":"$(id -g)" "$HOME/.local/share/nvim" "$HOME/.local/state/nvim/"
    fi

    # Create the virtual environment if not exists
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

    # Upgrade pip and install necessary Python packages
    log "Installing/upgrading Python dependencies for Neovim..." "$CYAN"
    pip install --upgrade pip >/dev/null 2>&1 || log "Error upgrading pip!" "$RED"
    pip install neovim 'python-lsp-server[all]' >/dev/null 2>&1 || log "Error installing Python dependencies!" "$RED"
    deactivate

    # Ensure npm is installed
    if ! command -v npm &> /dev/null; then
        log "npm not found! Please install Node.js and npm first." "$RED"
        exit 1
    fi

    # Set npm global installation path
    log "Setting up npm global installation path..." "$CYAN"
    mkdir -p "$NPM_GLOBAL_PATH"
    export PATH="$NPM_GLOBAL_PATH/bin:$PATH"
    echo "export PATH=\"$HOME/.npm-global/bin:\$PATH\"" >> "$HOME/.bashrc"


    # Set permissions for npm directory
    if [[ -d "$HOME/.npm" ]]; then
        log "Fixing permissions for .npm directory..." "$CYAN"
        sudo chown -R "$(id -u)":"$(id -g)" "$HOME/.npm"
    fi

    # Install Neovim-related npm packages
    log "Installing npm packages for Neovim..." "$CYAN"
    npm install -g neovim bash-language-server --prefix="$NPM_GLOBAL_PATH" >/dev/null 2>&1 || log "Error installing Neovim and bash-language-server (user-level)!" "$RED"
    sudo npm install -g neovim bash-language-server >/dev/null 2>&1 || log "Error installing Neovim and bash-language-server (system-wide)!" "$RED"

    # Source bashrc to ensure changes take effect
    log "Refreshing shell environment..." "$BLUE"
    # shellcheck source=/Users/behnam/.bashrc
    source ~/.bashrc
    # shellcheck source=/Users/behnam/.profile
    source ~/.profile
    # shellcheck source=/Users/behnam/.config/fish/config.fish
#    source ~/.config/fish/config.fish
    # Install Vim-Plug
    log "Installing Vim-Plug for Neovim..." "$CYAN"
    curl -s -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
         https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

    # Install Neovim plugins
    log "Installing Neovim plugins..." "$CYAN"
    nvim --headless +PlugInstall +qall

    # Install CoC extensions
    log "Installing coc.nvim extensions..." "$CYAN"
    nvim --headless -c 'CocInstall -sync coc-json coc-html coc-css coc-yaml coc-sh' -c 'qall'

    log "Neovim setup completed successfully!" "$GREEN"
}
setup_apt_proxy() {
    local PROXY="$1"  # Accept proxy URL as an argument
    local CONFIG_FILE="/etc/apt/apt.conf.d/01proxy"

    log "Checking APT proxy configuration..." "$BLUE"

    # Check if the configuration file already contains the expected proxy setting
    if [[ -f "$CONFIG_FILE" ]] && grep -qF "Acquire::http::Proxy  \"$PROXY\";" "$CONFIG_FILE"; then
        log "✅ APT proxy is already configured. No changes needed." "$GREEN"
    else
        log "⚠️ APT proxy is not configured. Setting it up now..." "$YELLOW"
        sudo bash -c "cat > $CONFIG_FILE" <<EOF
Acquire::http::Proxy  "$PROXY";
Acquire::https::Proxy "$PROXY";
EOF
        log "✅ APT proxy configured successfully!" "$GREEN"
    fi
}
manage_systemd_service() {
    local service_name="$1" is_active is_enabled

    # Check if the service is enabled
    is_enabled=$(systemctl is-enabled "$service_name" 2>/dev/null)

    # Check if the service is running
    is_active=$(systemctl is-active "$service_name" 2>/dev/null)

    if [[ "$is_enabled" == "enabled" && "$is_active" == "active" ]]; then
        log "✅ $service_name is already enabled and running." "$MAGENTA"
        log "Restarting $service_name..." "$BLUE"
        sudo systemctl restart "$service_name"

    elif [[ "$is_enabled" != "enabled" && "$is_active" == "active" ]]; then
        log "⚠️ $service_name is running but not enabled. Enabling it now..." "$YELLOW"
        sudo systemctl enable --now "$service_name"

    elif [[ "$is_enabled" == "enabled" && "$is_active" != "active" ]]; then
        log "⚠️ $service_name is enabled but not running. Starting it now..." "$YELLOW"
        sudo systemctl start "$service_name"

    else
        log "🚨 $service_name is neither enabled nor running. Enabling and starting..." "$CYAN"
        sudo systemctl enable --now "$service_name"
    fi
}
configure_singbox(){
  local CONFIG_DEST CONFIG_SOURCE FETCH_SCRIPT_DEST FETCH_SCRIPT_SOURCE CRON_ENTRY MODIFICATION_LINE MODIFICATION_LINE2

  # Ensure INSTALL_PROXY and PUBLIC_PROXY are set
  if [ "$INSTALL_PROXY" = true ]; then

      # Define source and destination paths for configuration
      CONFIG_SOURCE="/tmp/lab/var/www/subscription/sbox/routers.json"
      CONFIG_DEST="/etc/sing-box/config.json"

      # Check if the configuration file exists
      if [ -f "$CONFIG_SOURCE" ]; then
          log "Copying Sing-box configuration file..." "$MAGENTA"

          if ! [[ -d "/etc/sing-box" ]]; then
            sudo mkdir -p /etc/sing-box
          fi

          if cmp -s "$CONFIG_SOURCE" "$CONFIG_DEST"; then
            log "sing-box configuration is latest." "$GREEN"
          else
            sudo cp "$CONFIG_SOURCE" "$CONFIG_DEST"
            log "Configuration file copied successfully." "$GREEN"
          fi

          manage_systemd_service "sing-box"
      else
          log "Error: Configuration file not found at $CONFIG_SOURCE" "$RED"
          exit 1
      fi

      # === Install `sing-box-fetch.sh` Script ===
      FETCH_SCRIPT_SOURCE="/tmp/lab/home/bea/scripts/bea/sing-box-fetch.sh"
      FETCH_SCRIPT_DEST="/usr/local/bin/sing-box-fetch.sh"

      if [ -f "$FETCH_SCRIPT_SOURCE" ]; then
          log "Copying sing-box-fetch.sh to /usr/local/bin..." "$MAGENTA"

          if cmp -s "$FETCH_SCRIPT_SOURCE" "$FETCH_SCRIPT_DEST"; then
            log "Local script is the same as the remote script." "$GREEN"
          else
            sudo cp "$FETCH_SCRIPT_SOURCE" "$FETCH_SCRIPT_DEST"
            sudo chmod +x "$FETCH_SCRIPT_DEST"
            log "Sing-box fetch script installed successfully." "$GREEN"
          fi
          manage_systemd_service "sing-box"
      else
          log "Error: sing-box-fetch.sh not found in $FETCH_SCRIPT_SOURCE" "$RED"
          exit 1
      fi

      # === Add to Root Crontab if Not Already Present ===
      CRON_ENTRY="* * * * * /usr/local/bin/sing-box-fetch.sh >> /var/log/sing-box-fetch.log 2>&1"

      # Check if the cron entry already exists in the root's crontab
      if sudo crontab -l 2>/dev/null | grep -Fq "$CRON_ENTRY"; then
          log "✅ Cron job is already set. No changes needed." "$BLUE"
      else
          log "⚠️ Cron job not found. Adding it now..." "$MAGENTA"
          (sudo crontab -l 2>/dev/null; echo "$CRON_ENTRY") | sudo crontab -
          log "✅ Crontab updated successfully." "$GREEN"
      fi

      # Setup APT proxy if necessary
      if command -v apt &>/dev/null; then
          setup_apt_proxy "$PROXY"
      else
          log "Unsupported package manager. Skipping Sing-box installation." "$RED"
      fi

      # === Apply Public Proxy Settings ===
      if [ "$PUBLIC_PROXY" = true ]; then
          log "Applying public proxy settings to sing-box-fetch.sh..." "$MAGENTA"

          # Define the modification lines
          MODIFICATION_LINE="sed -i 's#\"listen\": \"127.0.0.1\",#\"listen\": \"0.0.0.0\",#g' /etc/sing-box/config.json"
          MODIFICATION_LINE2="sed -i 's#\"external_controller\": \"127.0.0.1:9090\"#\"external_controller\": \"0.0.0.0:9090\"#g' /etc/sing-box/config.json"

          # Check if modification already exists before appending
          if ! sudo grep -Fq "listen\": \"0.0.0.0" "$FETCH_SCRIPT_DEST"; then
              log "Appending public proxy modification to sing-box-fetch.sh..." "$MAGENTA"
              echo "$MODIFICATION_LINE" | sudo tee -a "$FETCH_SCRIPT_DEST" > /dev/null
              echo "$MODIFICATION_LINE2" | sudo tee -a "$FETCH_SCRIPT_DEST" > /dev/null

              manage_systemd_service "sing-box"
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
      git clone --bare git@github.com:behnambagheri/dotfiles.git "$HOME/.dotfiles" > /dev/null 2>&1
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


configure_helix(){
  if ! sudo test -L "/root/.config/helix"; then
    sudo rm -rf "/root/.config/helix"
  fi
  if ! sudo test -d "/root/.config"; then
    sudo mkdir "/root/.config"
  fi
  if ! sudo test -e "/root/.config/helix"; then
    sudo ln -s "$HOME/.config/helix" "/root/.config/helix"
  fi
#  sudo mkdir -p /root/.config/helix
#  sudo cp -r "$HOME/.config/helix/config.toml" "/root/.config/"
}

cleanup(){
  # Clean up the cloned repository
  log "🧹 Cleaning up temporary files..." "$BLUE"
  for arg in "$@"; do
    if [[ -d "$arg" ]]; then
      rm -rf "$arg"
      log "DIR: $arg Deleted." "$YELLOW"
    fi
  done

}

remove_features(){
  local PLUGINS
  # Define plugins list
  PLUGINS=(
    "wfxr/forgit"
    "gazorby/fifc"
  )

  # Check and install missing plugins
  for plugin in "${PLUGINS[@]}"; do
    if fish -c "fisher list | grep -q \"$plugin\""; then
      fish -c "fisher remove $plugin" > /dev/null 2>&1 || log "Error Removing $plugin" "$RED"
    else
      log "Plugin $plugin is already Removed. Skipping..." "$YELLOW"
    fi
  done


}

source_varibales(){
  log "source variables..." "$BLUE"
  fish -c "source $HOME/.local/dotfiles/variables.fish"
}


clone_projects "git@github.com:behnambagheri/lab.git" "/tmp/lab"
install_packages
configure_fish
#configure_bat
#configure_vim
#configure_nvim
configure_helix
configure_singbox
initialize_config
source_varibales
remove_features
cleanup "/tmp/lab" "/tmp/dotfiles"

log "Dotfiles installation and Fish setup complete!" "$GREEN"
