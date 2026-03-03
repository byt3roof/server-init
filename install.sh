#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

set -e

GO_VERSION="1.26.0"

# OS detection (ubuntu or debian)
OS_ID=$(grep -oP '(?<=^ID=).*' /etc/os-release | tr -d '"')
echo "detected OS: $OS_ID"

# Architechture detection
ARCH=$(uname -m)
case $ARCH in
  x86_64) ARCH_GO="amd64"; ARCH_BUN="x64" ;;
  aarch64) ARCH_GO="arm64"; ARCH_BUN="aarch64" ;;
  *) echo "unsupported architecture: $ARCH"; exit 1 ;;
esac

echo "dectected architecture: $ARCH"

exists() {
  command -v "$1" >/dev/null 2>&1
}

setup_environment() {
  echo "--- updating sys packages ---"
  apt update -y && apt upgrade -y
  apt-get install -y curl wget git build-essential unzip lsb-release
}

install_go() {
  if exists go; then
    echo "go is already installed, skipping..."
  else
    echo "--- installing go ---"
    wget "https://go.dev/dl/go${GO_VERSION}.linux-${ARCH_GO}.tar.gz"
    rm -rf /usr/local/go && tar -C /usr/local -xzf "go${GO_VERSION}.linux-${ARCH_GO}.tar.gz"
    ln -sf /usr/local/go/bin/go /usr/local/bin/go
    rm "go${GO_VERSION}.linux-${ARCH_GO}.tar.gz"
  fi
}

install_bunjs() {
  if exists bun; then
    echo "bun is already installed, skipping..."
  else
    echo "--- installing bun ---"
    curl -fsSL https://bun.sh/install | bash
    ln -sf /root/.bun/bin/bun /usr/local/bin/bun
  fi
}

install_docker() {
  if exists docker; then
    echo "docker is already installed, skipping..."
  else
    echo "--- installing docker engine & compose ---"
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL "https://download.docker.com/linux/${OS_ID}/gpg" | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/${OS_ID} \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt update
    apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    systemctl enable docker --now

    if [ -n "$SUDO_USER" ]; then
      usermod -aG docker "$SUDO_USER"
      echo "user $SUDO_USER added to docker group"
    fi
  fi
}

install_oh_my_bash() {
  if [ -d "$HOME/.oh-my-bash" ]; then
    echo "Oh My Bash is already installed. Skipping..."
  else
    echo "--- Installing Oh My Bash ---"
    git clone https://github.com/ohmybash/oh-my-bash.git "$HOME/.oh-my-bash"
    cp "$HOME/.oh-my-bash/templates/bashrc.osh-template" "$HOME/.bashrc"
    sed -i 's/OSH_THEME="font"/OSH_THEME="half-life"/' $HOME/.bashrc
    sed -i 's/plugins=(git)/plugins=(git bash-completion docker docker-compose node npm)/' $HOME/.bashrc
    echo "Theme set to: Half-Life"
  fi
}

main() {
  setup_environment
  install_oh_my_bash
  install_go
  install_bunjs
  install_docker

  echo "--- --- --- --- --- --- --- --- ---"
  echo "installation complete"
  echo "shell: oh my bash installed"
  echo "go: $(go version)"
  echo "bun: $(bun -v)"
  echo "docker: $(docker --version)"
  echo "docker compose: $(docker compose version)"
  echo "NOTE you may need to log out and log back in for shell and docker group changes to take effect"
  echo "--- --- --- --- --- --- --- --- ---"
}

main
