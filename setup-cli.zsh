#!/usr/bin/env zsh

OS="$(uname -s)"
if read -qs "interactive?Prompt before overwrite? [y/N]:"; then
  alias cp="cp -i"
else
  alias cp="cp"
fi
echo ""

case "${OS}" in
    Darwin*)
        # SKIP: Copy needed files by yourself.
        ;;
    Linux*)
        # Zsh
        cp ./zshrc.basic.zsh ${HOME}/.zshrc.basic.zsh
        cp ./${OS}/zshrc.zsh ${HOME}/.zshrc
        cp ./${OS}/zshenv.zsh ${HOME}/.zshenv
        cp ./functions.zsh ${HOME}/.functions.zsh

        # Vim
        cp ./.{vimrc,basic.vimrc,plug.vimrc} ${HOME}/

        # Git
        cp ./.gitignore_global ${HOME}/

        # Tmux
        cp ./.tmux.conf ${HOME}/
        ;;
    *)
        echo "Unknown OS: ${OS}"
esac

# ==========
# Git config
# ==========

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
cp ./.gitconfig ${HOME}/

if [ -z "$git_username" ]; then
  # Not configured, prompt to configure
  gitconfig
else
  # Restore git username/email
  git config --global user.name ${git_username}
  git config --global user.email ${git_email}
  if [ "$git_signingkey" ]; then
    git config --global user.signingkey ${git_signingkey}
  fi
fi

if read -qs "sign?Automatically sign git commits? [y/N]:"; then
  git config --global commit.gpgsign true
  git config --global gpg.program $(which gpg)
else
  git config --global commit.gpgsign false
fi
echo ""

# Reset alias
unalias cp
