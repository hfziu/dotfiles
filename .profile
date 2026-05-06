# ~/.profile
# This file is sourced by POSIX-compliant shells and can be sourced by zsh/bash

OS="$(uname)"

# Drop-in configs
if [ -d "$HOME/.profile.d" ]; then
  for file in "$HOME/.profile.d/"*; do
    [ -r "$file" ] && . "$file"
  done
fi
