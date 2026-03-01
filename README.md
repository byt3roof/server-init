# server-init

A single-script for ubuntu servers. Installs and configures a base development environment in one command.

## What it installs

| Tool | Details |
|------|---------|
| **Oh My Bash** | Shell framework — Half-Life theme, plugins: `git bash-completion docker docker-compose node npm` |
| **Go** | Compiled from official tarball (`/usr/local/go`) |
| **Bun** | JavaScript runtime + package manager |
| **Docker** | Docker Engine + Docker Compose plugin, enabled on boot |

Each tool is skipped automatically if it's already present.

## Requirements

- Ubuntu (x86_64 or aarch64)
- Root access

## Usage

```bash
curl -fsSL https://raw.githubusercontent.com/byt3roof/server-init/main/install.sh | sudo bash
```

Or clone and run locally:

```bash
git clone https://github.com/byt3roof/server-init.git
cd server-init
sudo bash install.sh
```

## Configuration

Edit the top of `install.sh` to change the Go version before running:

```bash
GO_VERSION="1.24.0"
```

## Notes

- Docker group changes and shell updates require a **log out / log back in** to take effect
- Bun is symlinked to `/usr/local/bin/bun` for system-wide access
- Oh My Bash is installed by cloning the repo to `~/.oh-my-bash`
