export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

## Add Homebrew/bin and ~/.local/bin to PATH if not present 
(( $PATH[(I)/usr/local/sbin] )) || export PATH="/usr/local/sbin:$PATH"
(( $PATH[(I)/usr/local/bin] )) || export PATH="/usr/local/bin:$PATH"
(( $PATH[(I)$HOME/.local/bin] )) || export PATH="$HOME/.local/bin:$PATH"

(( $PATH[(I)/opt/homebrew/bin] )) || export PATH="/opt/homebrew/bin:$PATH"
(( $PATH[(I)/opt/homebrew/sbin] )) || export PATH="/opt/homebrew/sbin:$PATH"
# Homebrew completion
(( $+commands[brew] )) && FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"

## Go
(( $+commands[go] )) && export GOPATH=$HOME/Developer/local/go && export PATH=$GOPATH/bin:$PATH

## Rust
[[ -f $HOME/.cargo/env ]] && source $HOME/.cargo/env

## OpenJDK installed by Homebrew on Apple Silicon
OPENJDK_HOME=/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home
if [ -d $OPENJDK_HOME ]; then
  JAVA_HOME=$OPENJDK_HOME
fi

## Save command history
# The following three lines already exist in the system-wide ZSH profile on macOS (/etc/zshrc)
# but in some systems (e.g. Arch Linux) the variables may need to be explicitly set in user profile (~/.zshenv)
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=2000
SAVEHIST=1000

## TeX Live native package on Linux installed in /usr/local/texlive
TEXLIVE_NATIVE_BIN=/usr/local/texlive/2023/bin/x86_64-linux
if [ -d $TEXLIVE_NATIVE_BIN ]; then
  (( $PATH[(I)$TEXLIVE_NATIVE_BIN] )) || export PATH="$TEXLIVE_NATIVE_BIN:$PATH"
fi

## I'm in Mainland China
# Homebrew-bottles
[[ -f $HOME/.iminchina ]] && export HOMEBREW_BOTTLE_DOMAIN="https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles"
[[ -f $HOME/.iminchina ]] || unset HOMEBREW_BOTTLE_DOMAIN

# Homebrew PATH
# -------------
HOMEBREW_GNUBIN=/opt/homebrew/opt/make/libexec/gnubin
PATH="$HOMEBREW_GNUBIN:$PATH"
