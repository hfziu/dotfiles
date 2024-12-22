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
        # * Mainland China software mirror settings
        cp ${HOME}/.cn.env ./.cn.env

        # Remove personal info in git-config file
        awk '!/name = |email = |signingkey = |essethon|stdgeodesic|127.0.0.1/' ${HOME}/.gitconfig > ./.gitconfig

        # Tmux
        cp ${HOME}/.tmux.conf ./
        ;;
    Linux*)
        cp ${HOME}/.zshrc ./${OS}/zshrc.zsh
        cp ${HOME}/.zshenv ./${OS}/zshenv.zsh
        ;;
    *)
        echo "Unknown OS: ${OS}"
esac

# Backup software settings
if [ -f "${HOME}/.config/kitty/kitty.conf" ]; then
  cp -r ${HOME}/.config/kitty ./.config/
fi

# as of Dec 2024, I started using lazyvim.org
# if [ -d "${HOME}/.config/nvim" ]; then
#   cp -r ${HOME}/.config/nvim ./.config/
# fi

if [ -f "${HOME}/.config/zed/settings.json" ]; then
  mkdir -p ./.config/zed
  cp ${HOME}/.config/zed/settings.json ./.config/zed/
fi
