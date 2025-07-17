export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

## Add /usr/local/bin and ~/.local/bin to PATH if not present 
(( $PATH[(I)/usr/local/sbin] )) || export PATH="/usr/local/sbin:$PATH"
(( $PATH[(I)/usr/local/bin] )) || export PATH="/usr/local/bin:$PATH"
(( $PATH[(I)$HOME/.local/bin] )) || export PATH="$HOME/.local/bin:$PATH"


# =============================
# Linux Workstation - SSH Agent
# =============================

# The ssh-agent.service (systemd) included with openssh creates a socket at $XDG_RUNTIME_DIR/ssh-agent.socket.
# - If this is not an SSH session, we try to use the socket created by ssh-agent.service.
# - Otherwise for an SSH session, the SSH agent might have been forwarded from the client and the SSH_AUTH_SOCK variable is set accordingly.
#     We don't overwrite it.
BITWARDEN_SSH_AGENT_SOCK="$HOME/.bitwarden-ssh-agent.sock"
if [ -z "$SSH_CONNECTION" ]; then
    if [ -e "$XDG_RUNTIME_DIR/ssh-agent.socket" ]; then
        export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
    fi
    # If Bitwarden SH Agent is enabled, use it as the SSH_AUTH_SOCK (overrides the above)
    if [ -S "$BITWARDEN_SSH_AGENT_SOCK" ]; then
        export SSH_AUTH_SOCK="$BITWARDEN_SSH_AGENT_SOCK"
    fi
fi
# -----------------------------

## Save command history
# The following three lines already exist in the system-wide ZSH profile on macOS (/etc/zshrc)
# but in some systems (e.g. Arch Linux) the variables may need to be explicitly set in user profile (~/.zshenv)
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=2000
SAVEHIST=1000

## Software
# Rustup
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi