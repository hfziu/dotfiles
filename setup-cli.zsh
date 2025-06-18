#!/usr/bin/env zsh

OS="$(uname -s)"
PWD="$(cd "$(dirname "$0")" && pwd)"
if read -qs "interactive?Prompt before overwrite? [y/N]:"; then
  alias cp="cp -i"
else
  alias cp="cp"
fi
echo ""

if [[ "${OS}" != "Darwin" && "${OS}" != "Linux" ]]; then
  echo "Unknown OS: ${OS}. Only macOS (Darwin) and Linux are supported."
  exit 1
fi

# Zsh
cp ${PWD}/zsh/zshrc.basic.zsh ${HOME}/.zshrc.basic.zsh
cp ${PWD}/zsh/functions.zsh ${HOME}/.functions.zsh
cp ${PWD}/zsh/zshrc.${OS:l}.zsh ${HOME}/.zshrc
cp ${PWD}/zsh/zshenv.${OS:l}.zsh ${HOME}/.zshenv

# Vim
cp ${PWD}/vim/.{vimrc,basic.vimrc,plug.vimrc} ${HOME}/

# Ghostty
(( $+commands[ghostty] )) && \
mkdir -p ${HOME}/.config/ghostty && \
cp ${PWD}/ghostty/config{,.${OS:l}} ${HOME}/.config/ghostty/

# Tmux
cp ${PWD}/.tmux.conf ${HOME}/

# ==========
# Git config
# ==========

# Gitignore
cp ${PWD}/git/.gitignore_global ${HOME}/

gitconfig() {
  read "git_username?Please input Git Username: "
  read "git_email?Please input Git Email: "

  git config --global user.name "${git_username}"
  git config --global user.email "${git_email}"
}

# Backup git username before overwrite ~/.gitconfig
git_username=$(git config --global user.name)
git_email=$(git config --global user.email)
git_signingkey=$(git config --global user.signingkey)
git_credentials=$(git config --global credential.helper)
cp ${PWD}/git/.gitconfig ${HOME}/

if [ -z "$git_username" ]; then
  # Not configured, prompt to configure
  gitconfig
else
  # Restore git username/email
  git config --global user.name ${git_username}
  git config --global user.email ${git_email}
  (( ${+git_credentials} )) && git config --global credential.helper ${git_credentials}
  (( ${+git_signingkey} )) && git config --global user.signingkey ${git_signingkey}
fi

if read -qs "sign?Automatically sign git commits? [y/N]:"; then
  git config --global commit.gpgsign true
else
  git config --global commit.gpgsign false
fi
echo ""

# Reset alias
unalias cp
