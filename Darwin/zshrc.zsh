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
# Python2 is deprecated in recent macOS versions.
# Default `python` to `python3`.
alias python="python3"


# =================
# macOS - 3rd Party 
# =================

# Pyenv
# -----
export PYENV_ROOT="$HOME/.pyenv"
(( $+commands[pyenv] )) && zsh-defer eval "$(pyenv init -)" && zsh-defer eval "$(pyenv virtualenv-init -)"

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

