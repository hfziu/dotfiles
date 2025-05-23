# =====================
# Shared Configurations
# =====================
source ~/.zshrc.basic.zsh


# ================
# macOS - Zsh Conf 
# ================

# Disable Beeps
unsetopt BEEP

# Alias
# -----
# Just for fun
alias please="sudo"
alias 才="cd"
# BSD Style ls alias
alias ls="ls -G"
alias la="ls -aG"
alias ll="ls -aGl"
alias lh="ls -aGhl"
alias mv='mv -i'
# shortcut to open current dir in finder
alias ofd="open -R ."


# =================
# macOS - 3rd Party 
# =================

# uv
# --
(( $+commands[uv] )) && eval "$(uv generate-shell-completion zsh)" && eval "$(uvx --generate-shell-completion zsh)"

# Pyenv
# -----
# export PYENV_ROOT="$HOME/.pyenv"
# (( $+commands[pyenv] )) && zsh-defer eval "$(pyenv init -)" && zsh-defer eval "$(pyenv virtualenv-init -)"

# fnm (Node Version Manager)
# --------------------------
# I'm not a Node.js developer, but I need npm to install some tools.
# Since nvm is a bit heavy for my shell, I use fnm instead for better performance.
(( $+commands[fnm] )) && eval "$(fnm env)"

# GPG Agent
# ---------
export GPG_TTY="$TTY"
# zsh-defer export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
zsh-defer gpg-connect-agent updatestartuptty /bye > /dev/null

# iTerm2 shell integration
# ------------------------
# zsh-defer test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh" || true

function iterm2_print_user_vars() {
	iterm2_set_user_var proxy_status $([ -z "$ALL_PROXY" ] || echo "📡")
}

