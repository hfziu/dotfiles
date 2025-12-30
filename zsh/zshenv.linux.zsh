# Source common profile for SSH agent configuration
[ -f "$HOME/.profile" ] && . "$HOME/.profile"

export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

## Add /usr/local/bin and ~/.local/bin to PATH if not present 
(( $PATH[(I)/usr/local/sbin] )) || export PATH="/usr/local/sbin:$PATH"
(( $PATH[(I)/usr/local/bin] )) || export PATH="/usr/local/bin:$PATH"
(( $PATH[(I)$HOME/.local/bin] )) || export PATH="$HOME/.local/bin:$PATH"

## Save command history
# The following three lines already exist in the system-wide ZSH profile on macOS (/etc/zshrc)
# but in some systems (e.g. Arch Linux) the variables may need to be explicitly set in user profile (~/.zshenv)
HISTFILE=${ZDOTDIR:-$HOME}/.zsh_history
HISTSIZE=2000
SAVEHIST=1000

## Software
# Rustup
if [ -f "$HOME/.cargo/env" ]; then
  . "$HOME/.cargo/env"
fi