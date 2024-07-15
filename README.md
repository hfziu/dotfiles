# Configuration files

This repository contains configuration files for various programs that I use:

- `zsh` (shell): with the lightweight plugin manager [Antidote.lite](https://github.com/mattmc3/zsh_unplugged).
- `vim` (text editor): with plugin manager [Vim-Plug](https://github.com/junegunn/vim-plug).
- `tmux` (terminal multiplexer): *WARNING*: I changed the default prefix to `C-a` instead of `C-b`.
- `kitty` (terminal emulator): [Documentation](https://sw.kovidgoyal.net/kitty/).
- [Neovim](https://github.com/neovim/neovim)

## Usage

Copy the files to the appropriate locations (e.g., your `$HOME` directory). The `setup-cli.sh` script can be used to automate this process on Linux (only applicable for some of the configuration files).

Example:

```zsh
# For zsh on macOS
cp -i ./zshrc.basic.zsh ~/.zshrc.basic.zsh
cp -i ./Darwin/zshrc.zsh ~/.zshrc
cp -i ./Darwin/zshenv.zsh ~/.zshenv

# Open-source mirrors in Mainland China
# * Copy the following file ONLY if you are in Mainland China
cp -i ./.cn.env /.cn.env

# Vim
./install_dependencies.sh  # install Vim-Plug
cp -i {.basic.,.plug.,.}vimrc ~/
```

### Auto-completion

For zsh auto-completion, create a custom zsh function directory in `~/`:

```zsh
mkdir -p ~/.zfunc
```

The generate the auto-completion files, e.g., for `rustup` and `cargo`:

```zsh
rustup completions zsh > ~/.zfunc/_rustup
cargo completions zsh > ~/.zfunc/_cargo
```

## Compatibility

### macOS

Tested on macOS 14 (Ventura) with `zsh` version `zsh 5.9 (x86_64-apple-darwin23.0)`. Please note that compatibility is not guaranteed for very old versions of macOS, such as macOS versions before 10.13 (High Sierra) with `zsh` versions earlier than `5.3`.

*Note*: `setup-cli.sh` currently does nothing on macOS.

### Linux

## To-do
