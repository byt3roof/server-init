#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "Please run as root"
  exit
fi

set -e

GO_VERSION="1.26.0"

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
  apt-get install -y curl wget git build-essential unzip
}
