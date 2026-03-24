# Source common profile for SSH agent configuration
[ -f "$HOME/.profile" ] && . "$HOME/.profile"

export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

## Mainland China mirrors
if [ -f "$HOME/.cn.env" ]; then
  . "$HOME/.cn.env"
fi

## Homebrew
if [ -x /opt/homebrew/bin/brew ]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

if [[ -v HOMEBREW_PREFIX ]]; then  # requires zsh 5.3 or later
  # OpenJDK installed by Homebrew
  OPENJDK_HOME=$HOMEBREW_PREFIX/opt/openjdk/libexec/openjdk.jdk/Contents/Home
  # Homebrew-installed gnu utils
  export PATH="$HOMEBREW_PREFIX/opt/make/libexec/gnubin:$PATH"
fi

## Add /usr/local/bin and ~/.local/bin to PATH if not present
(( $PATH[(I)/usr/local/sbin] )) || export PATH="/usr/local/sbin:$PATH"
(( $PATH[(I)/usr/local/bin] )) || export PATH="/usr/local/bin:$PATH"
(( $PATH[(I)$HOME/.local/bin] )) || export PATH="$HOME/.local/bin:$PATH"

## OpenJDK
if [ -d $OPENJDK_HOME ]; then
  JAVA_HOME=$OPENJDK_HOME
fi

## Go
if (( $+commands[go] )) && [ ! -f "$(go env GOENV)" ]; then
  go env -w GOPATH="$HOME/.local/go"
  go env -w GOBIN="$HOME/.local/bin"
fi

# Rustup
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi
