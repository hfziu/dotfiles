#!/bin/bash

OS="$(uname -s)"
mkdir -p ./${OS}

case "${OS}" in
    Darwin*)
        cp ${HOME}/.{vimrc,basic.vimrc,plug.vimrc} ./
        cp ${HOME}/.gitignore_global ./

        # Zsh configurations
        cp ${HOME}/.zshrc.basic.zsh ./zshrc.basic.zsh
        cp ${HOME}/.zshrc ./${OS}/zshrc.zsh
        cp ${HOME}/.zshenv ./${OS}/zshenv.zsh
        cp ${HOME}/.functions.zsh ./functions.zsh

        # Remove personal info in git-config file
        awk '!/name = |email = |signingkey = |essethon|stdgeodesic|127.0.0.1/' ${HOME}/.gitconfig > ./.gitconfig
        cp ${HOME}/.tmux.conf ./
        ;;
    Linux*)
        cp ${HOME}/.zshrc ./${OS}/zshrc.zsh
        cp ${HOME}/.zshenv ./${OS}/zshenv.zsh
        ;;
    *)
        echo "Unknown OS: ${OS}"
esac

if [ -f "${HOME}/.config/kitty/kitty.conf" ]; then
  cp ${HOME}/.config/kitty/kitty.conf ./.config/kitty/
fi

