# This file contains the zsh plugin manager configurations and some commonly used zsh settings 
# that can be shared across different operating systems.
# It is intended to be sourced in the main .zshrc file (maybe OS-specific).

# =============
# ZSH_UNPLUGGED
# =============
# https://github.com/mattmc3/zsh_unplugged

# set path
# VSCode's shell integration set $ZDOTDIR to $HOME so we use a different variable $ZSH_CUSTOM
: ${ZSH_CUSTOM:=$HOME/.config/zsh}
# we save the plugins in a location other than ~/.config
: ${ANTIDOTE_LITE_HOME:=${XDG_CACHE_HOME:-~/.cache}/antidote.lite}

if [[ ! -f $ZSH_CUSTOM/lib/antidote.lite.zsh ]]; then
  mkdir -p $ZSH_CUSTOM/lib
  curl -L https://raw.githubusercontent.com/mattmc3/zsh_unplugged/main/antidote.lite.zsh \
    -o $ZSH_CUSTOM/lib/antidote.lite.zsh
fi
source $ZSH_CUSTOM/lib/antidote.lite.zsh

# make a github repo plugins list
prompts=(
  sindresorhus/pure
)
plugins=(
  romkatv/zsh-defer
  zdharma-continuum/fast-syntax-highlighting
  zsh-users/zsh-autosuggestions
  zsh-users/zsh-history-substring-search
  zsh-users/zsh-completions
)
# Clone and load the plugins
plugin-clone $prompts $plugins
plugin-load --kind fpath $prompts
plugin-load $plugins

# Initialize completion
# ---------------------
fpath+=~/.zfunc # custom zsh functions
unsetopt LIST_BEEP  # disable beep on an ambiguous completion
zstyle ':completion:*' completer _complete
# Allow autocomplete from the middle of filename
# https://stackoverflow.com/questions/22600259/zsh-autocomplete-from-the-middle-of-filename
zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
autoload -Uz compinit && compinit

# Prompt
# ------
autoload -U promptinit && promptinit
prompt pure

# ======================
# 3rd Party Applications
# ======================
# The following configurations may be used in both macOS and Linux

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


# ===================
# Import Environments
# ===================

# Credentials, e.g. Homebrew Github API Token
[[ -f ~/.credentials ]] && source ~/.credentials

# Include user functions
[[ -f ~/.functions.zsh ]] && source ~/.functions.zsh

# vim: ft=zsh sw=2 ts=2 et
