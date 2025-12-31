# ~/.profile
# This file is sourced by POSIX-compliant shells and can be sourced by zsh/bash

OS="$(uname)"

# Setup SSH Agent
if [ -z "$SSH_CONNECTION" ] && [ -z "$SSH_TTY" ]; then    
    if [ "$OS" = "Darwin" ]; then
        # macOS - Use Bitwarden SSH Agent if available
        BITWARDEN_SSH_SOCK="$HOME/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock"
        if [ -S "$BITWARDEN_SSH_SOCK" ]; then
            SSH_AUTH_SOCK="$BITWARDEN_SSH_SOCK"
            export SSH_AUTH_SOCK
        fi
    elif [ "$OS" = "Linux" ]; then
        # Linux - Prefer Bitwarden SSH Agent, fallback to systemd socket
        BITWARDEN_FLATPAK_SOCK="$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock"
        BITWARDEN_SSH_SOCK="$HOME/.bitwarden-ssh-agent.sock"
        
        if [ -S "$BITWARDEN_FLATPAK_SOCK" ]; then
            SSH_AUTH_SOCK="$BITWARDEN_FLATPAK_SOCK"
            export SSH_AUTH_SOCK
        elif [ -S "$BITWARDEN_SSH_SOCK" ]; then
            SSH_AUTH_SOCK="$BITWARDEN_SSH_SOCK"
            export SSH_AUTH_SOCK
        elif [ -n "$XDG_RUNTIME_DIR" ] && [ -S "$XDG_RUNTIME_DIR/ssh-agent.socket" ]; then
            SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
            export SSH_AUTH_SOCK
        fi
    fi
else
    # In an SSH session
    # SSH automatically sets SSH_AUTH_SOCK when agent forwarding is enabled
    # Don't override it
    :
fi

# Drop-in configs
if [ -d "$HOME/.profile.d" ]; then
  for file in "$HOME/.profile.d/"*; do
    [ -r "$file" ] && . "$file"
  done
fi
