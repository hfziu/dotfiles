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

# Pyenv
# -----
export PYENV_ROOT="$HOME/.pyenv"
(( $+commands[pyenv] )) && zsh-defer eval "$(pyenv init -)"
(( $+commands[pyenv-virtualenv] )) && zsh-defer eval "$(pyenv virtualenv-init -)"
