# This file contains the zsh plugin manager configurations and some commonly used zsh settings
# that can be shared across different operating systems.
# It is intended to be sourced in the main .zshrc file (maybe OS-specific).

# Core paths
# ----------
: ${ZDOTDIR:=$HOME}
: ${ZSH_PLUGINS_ROOT:=${ZDOTDIR}/.zsh_plugins}
: ${ZSH_PLUGINS_FILE:=${ZDOTDIR}/.zsh_plugins.txt}
: ${XDG_CACHE_HOME:=${HOME}/.cache}
: ${ZSH_CACHE_DIR:=${XDG_CACHE_HOME}/zsh}
: ${ZSH_COMPDUMP:=${ZSH_CACHE_DIR}/.zcompdump-${HOST}-${ZSH_VERSION}}

typeset -gU fpath
mkdir -p -- "${HOME}/.zfunc" "${ZSH_CACHE_DIR}/completions"
fpath+=("${HOME}/.zfunc")

# Shell behavior
# --------------
setopt AUTO_CD
setopt AUTO_PUSHD
setopt EXTENDED_GLOB
setopt INTERACTIVE_COMMENTS
setopt PUSHD_IGNORE_DUPS
setopt APPEND_HISTORY
setopt INC_APPEND_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

# Plugin loading
# --------------
# Antidote
# --------
# https://github.com/mattmc3/antidote
load_zsh_plugins() {
  local antidote_source="${ZDOTDIR}/.antidote/antidote.zsh"
  local zsh_plugins_static_file="${ZSH_PLUGINS_ROOT}.zsh"
  local plugins_loaded=false

  if [[ -r "$antidote_source" ]]; then
    source "$antidote_source"
    if [[ -f "$ZSH_PLUGINS_FILE" ]]; then
      if [[ ! "$zsh_plugins_static_file" -nt "$ZSH_PLUGINS_FILE" ]]; then
        antidote bundle <"$ZSH_PLUGINS_FILE" >|"$zsh_plugins_static_file"
      fi
      source "$zsh_plugins_static_file" && plugins_loaded=true
    else
      print -u2 -- "zsh: missing plugin bundle file: ${ZSH_PLUGINS_FILE}"
    fi
  else
    print -u2 -- "zsh: antidote is not installed; run setup-cli.zsh or install antidote first"
  fi

  return 0
}

setup_completion() {
  local -a existing_compdump stale_compdump custom_completions
  local rebuild_compdump=false

  unsetopt LIST_BEEP  # disable beep on an ambiguous completion
  zmodload zsh/complist
  zstyle ':completion:*' completer _complete
  zstyle ':completion:*' use-cache on
  zstyle ':completion:*' cache-path "${ZSH_CACHE_DIR}/completions"
  zstyle ':completion:*' menu select
  # Allow autocomplete from the middle of filename
  # https://stackoverflow.com/questions/22600259/zsh-autocomplete-from-the-middle-of-filename
  zstyle ':completion:*' matcher-list '' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' '+l:|=* r:|=*'
  autoload -Uz compinit
  existing_compdump=( "${ZSH_COMPDUMP}"(#qN) )
  stale_compdump=( "${ZSH_COMPDUMP}"(#qN.mh+24) )
  custom_completions=( "${HOME}"/.zfunc/_*(N-.) )

  if (( ${#existing_compdump} == 0 || ${#stale_compdump} != 0 )); then
    rebuild_compdump=true
  else
    local completion_file
    for completion_file in "${custom_completions[@]}"; do
      if [[ "$completion_file" -nt "${ZSH_COMPDUMP}" ]]; then
        rebuild_compdump=true
        break
      fi
    done
  fi

  if $rebuild_compdump; then
    compinit -d "${ZSH_COMPDUMP}"
  else
    compinit -C -d "${ZSH_COMPDUMP}"
  fi
}

# Interactive widgets and key bindings
# ------------------------------------
setup_widgets() {
  if (( $+functions[history-substring-search-up] && $+functions[history-substring-search-down] )); then
    bindkey '^[[A' history-substring-search-up
    bindkey '^[[B' history-substring-search-down
    bindkey '^[OA' history-substring-search-up
    bindkey '^[OB' history-substring-search-down
  fi

  if (( $+functions[autosuggest-accept] )); then
    bindkey '^[[C' autosuggest-accept
    bindkey '^[OC' autosuggest-accept
  fi

  autoload -Uz edit-command-line
  zle -N edit-command-line
  bindkey '^X^E' edit-command-line

  autoload -Uz bracketed-paste-magic
  zle -N bracketed-paste bracketed-paste-magic

  bindkey ' ' magic-space
}

# Prompt
# ------
setup_prompt() {
  if (( $+commands[starship] )); then
    eval "$(starship init zsh)"
    return 0
  fi
  
  setopt PROMPT_SUBST
  PROMPT='%F{blue}%~%f %# '
}

# Startup flow
# ------------
load_zsh_plugins
setup_completion
setup_widgets
setup_prompt

unfunction load_zsh_plugins
unfunction setup_completion
unfunction setup_widgets
unfunction setup_prompt

# ======================
# 3rd Party Applications
# ======================
# The following configurations may be used in both macOS and Linux

# uv
# --
(( $+commands[uv] )) && export UV_TORCH_BACKEND=auto


# ===================
# Import Environments
# ===================

# Credentials, e.g. Homebrew Github API Token
[[ -f ~/.credentials ]] && source ~/.credentials

# Include user functions
[[ -f ~/.functions.zsh ]] && source ~/.functions.zsh

# vim: ft=zsh sw=2 ts=2 et
