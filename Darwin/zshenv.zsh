export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

## Homebrew
if [ -d /opt/homebrew ]; then  # Apple Silicon
  export HOMEBREW_PREFIX=/opt/homebrew
elif [ -d /usr/local/homebrew ]; then  # Intel
  export HOMEBREW_PREFIX=/usr/local
fi

if [[ -v HOMEBREW_PREFIX ]]; then  # requires zsh 5.3 or later
  export PATH="$HOMEBREW_PREFIX/sbin:$HOMEBREW_PREFIX/bin:$PATH"
  # completion for zsh
  FPATH="$HOMEBREW_PREFIX/share/zsh/site-functions:${FPATH}"
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

# Rustup
if [ -f "$HOME/.carge/env" ]; then
  . "$HOME/.cargo/env"
fi
