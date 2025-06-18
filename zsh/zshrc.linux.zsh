# =====================
# Shared Configurations
# =====================
source ~/.zshrc.basic.zsh


# ================
# Linux - Zsh Conf
# ================

# Alias
# -----
alias please="sudo"
# GNU style ls alias
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias ls='ls --color=auto'
alias mv='mv -i'


# =================
# Linux - 3rd Party
# =================


# =============================
# Linux Workstation - SSH Agent
# =============================
# The ssh-agent.service (systemd) included with openssh creates a socket at $XDG_RUNTIME_DIR/ssh-agent.socket.
# - If this is not an SSH session, we try to use the socket created by ssh-agent.service.
# - Otherwise for an SSH session, the SSH agent might have been forwarded from the client and the SSH_AUTH_SOCK variable is set accordingly.
#     We don't overwrite it.
if [ -z "$SSH_CONNECTION" ]; then
    if [ -e "$XDG_RUNTIME_DIR/ssh-agent.socket" ]; then
        export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"
    fi
fi
