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

# GNU coreutils customizations
# tell `ls` to color directories blue without bold
export LS_COLORS='di=0;34:'


# =================
# Linux - 3rd Party
# =================

# Pyenv
# -----
# I mainly use uv for managing Python environments,
# but since it doesn't support EOL Python versions,
# I sometimes use pyenv to install older Python versions on my Development machine.

export PYENV_ROOT="$HOME/.pyenv"
(( $+commands[pyenv] )) && zsh-defer eval "$(pyenv init -)" && zsh-defer eval "$(pyenv virtualenv-init -)"
