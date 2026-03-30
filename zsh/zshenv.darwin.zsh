# Source common profile for SSH agent configuration
[ -f "$HOME/.profile" ] && . "$HOME/.profile"

export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

## Mainland China mirrors
if [ -f "$HOME/.cn.env" ]; then
  . "$HOME/.cn.env"
fi

## Homebrew
export HOMEBREW_PREFIX="/opt/homebrew"
export HOMEBREW_CELLAR="${HOMEBREW_PREFIX}/Cellar"
export HOMEBREW_REPOSITORY="${HOMEBREW_PREFIX}"

typeset -gU path fpath
path=(
  "${HOMEBREW_PREFIX}/bin"
  "${HOMEBREW_PREFIX}/sbin"
  $path
)
fpath=(
  "${HOMEBREW_PREFIX}/share/zsh/site-functions"
  $fpath
)

[ -z "${MANPATH-}" ] || export MANPATH=":${MANPATH#:}"
export INFOPATH="${HOMEBREW_PREFIX}/share/info:${INFOPATH:-}"

## Add /usr/local/bin and ~/.local/bin to PATH if not present
(( $PATH[(I)/usr/local/sbin] )) || export PATH="/usr/local/sbin:$PATH"
(( $PATH[(I)/usr/local/bin] )) || export PATH="/usr/local/bin:$PATH"
(( $PATH[(I)$HOME/.local/bin] )) || export PATH="$HOME/.local/bin:$PATH"

## Mise
MISE_SHIMS_DIR="${MISE_DATA_DIR:-$HOME/.local/share/mise}/shims"
[[ -d "$MISE_SHIMS_DIR" ]] && path=("$MISE_SHIMS_DIR" $path)

## Go
if (( $+commands[go] )) && [ ! -f "$(go env GOENV)" ]; then
  go env -w GOPATH="$HOME/.local/go"
  go env -w GOBIN="$HOME/.local/bin"
fi

# Rustup
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi
