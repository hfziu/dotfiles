# Configuration files

This repository contains configuration for the tools I use:

- `zsh` (shell): with the plugin manager [Antidote](https://github.com/mattmc3/antidote)
- `vim` (text editor): with plugin manager [Vim-Plug](https://github.com/junegunn/vim-plug).
- `tmux` (terminal multiplexer): WARNING: prefix is set to `C-a` instead of the default `C-b`. This is purely a personal preference.
- ~~`kitty` (terminal emulator): [Documentation](https://sw.kovidgoyal.net/kitty/)~~ switched to Ghostty.
- [Ghostty](https://ghostty.org)
- [Neovim](https://github.com/neovim/neovim) with [lazy.nvim](https://github.com/folke/lazy.nvim)

## Install optional tools without administrative privileges

I use

- [uv](https://github.com/astral-sh/uv) for Python virtual environment management;
- [mise](https://github.com/jdx/mise) to manage other development tools & language runtimes (e.g., Node.js);
- [Starship](https://github.com/starship/starship) prompt in Zsh when `starship` command is available.

You may find the installation instructions in their official documentation. One advantage of such Rust-developed tools is that they can be easily installed without administrative privileges (most of them are single binary executables). For example:

```sh
# Starship
curl -sS https://starship.rs/install.sh | sh -s -- --bin-dir ~/.local/bin
```

The official installation scripts for `uv` and `mise` already default to installing the binaries to `~/.local/bin`.

### Mise

On multi-user servers where we don't have root access or don't want to mess with other users' runtime versions, `mise` can be a good option to manage development environments in a user-local way. See [mise documentation](https://mise.jdx.dev) for more details.

`uv` and `starship` can also be installed by `mise`:

```sh
mise use -g uv starship
```

The `$MISE_SHIMS_DIR` is prepended to `$path` in [.zshenv](zsh/zshenv.linux.zsh), so the `uv` and `starship` shims should be available when referenced in [.zshrc](zsh/zshrc.linux.zsh) (`.zshenv` is sourced before `.zshrc`).

We can also [activate `mise`](https://mise.jdx.dev/cli/activate.html) in Zsh by uncommenting the relevant lines in [zshrc.basic.zsh](zsh/zshrc.basic.zsh); since this will add some overhead to the shell startup time, I choose to keep it disabled by default and only enable it when needed.

## Usage (applying the configurations)

There is a `setup-cli.zsh` script that can automatically copy the configuration files to their designated locations. I recommend carefully reviewing the script (and those config files) before running it.

Alternatively, you can manually copy the files you need:

```zsh
# Zsh
git clone --depth=1 https://github.com/mattmc3/antidote.git ~/.antidote
cp -i zsh/zshrc.basic.zsh ~/.zshrc.basic.zsh
cp -i zsh/zsh_plugins.txt ~/.zsh_plugins.txt
cp -i zsh/zshrc.darwin.zsh ~/.zshrc
cp -i zsh/zshenv.darwin.zsh ~/.zshenv

# Open-source mirrors in Mainland China
# * The `.cn.env` file set some environment variables to use mirrors for Homebrew, Rust, etc., 
#   which may improve download speeds for Mainland China users.
#   This file is intentionally excluded from the setup script.
cp -i ./.cn.env ~/.cn.env

# Vim
vim/install_dependencies.sh  # install Vim-Plug
cp -i vim/{.basic.,.plug.,.}vimrc ~/
```

### Auto-completion

For zsh auto-completion, create a custom zsh function directory:

```zsh
mkdir -p ~/.zfunc
```

Then generate the auto-completion files, e.g., for `rustup` and `cargo`:

```zsh
rustup completions zsh > ~/.zfunc/_rustup
cargo completions zsh > ~/.zfunc/_cargo
```

## Compatibility

### macOS

Tested on macOS 26 with `zsh 5.9 (arm64-apple-darwin25.0)`. Compatibility with significantly older macOS releases (e.g., macOS pre-10.13 High Sierra with `zsh` < 5.3) is not guaranteed.
This repository assumes Apple Silicon macOS with Homebrew installed at `/opt/homebrew`. To improve startup time, this path is hardcoded in shell configuration files to avoid the overhead of calling `brew` to determine the Homebrew prefix.

### Linux

## To-do

### Fish shell

As of September 2025, I'm switching to fish. Since fish is not POSIX-compliant, I use it only as an interactive shell (the login shell remains Zsh or Bash) via my [terminal emulator settings](ghostty/config.darwin).

Compared to Zsh, fish offers superior out-of-the-box features, eliminating the need for complex configurations and third-party plugins (though there are some plugins and plugin managers available). My current [fish configuration](fish/config.fish) contains only environment variable settings for external programs (Homebrew, Bitwarden, Go, Rust, etc.). There are no configurations that modify the default behavior of fish itself (yet).

On Apple Silicon macOS, Homebrew installs fish to `/opt/homebrew/bin/fish`, which isn't in the standard `$PATH`, requiring the absolute path being hardcoded in the terminal emulator's configuration, for example, [Ghostty's](ghostty/config.darwin):

```ini
# TODO: find a portable method to launch the fish shell across different installation paths (standard $PATH or /opt/homebrew/bin/fish)
command = direct:/opt/homebrew/bin/fish --login --interactive
```

Current fish configurations are stored in [./fish](./fish) with the following structure:

```text
./fish/
├── config.fish
└── functions
    └── cn_mirrors.fish
```

The setup script `setup-cli.zsh` **doesn't** copy `./fish/functions` automatically. This isn't problematic (yet) since the few custom functions don't affect the main configuration's default behavior.

Your `~/.config/fish/` directory may also include files automatically generated or updated by fish (these files are *intentionally* excluded from this repository), such as:

- `fish_variables` (stores universal variables that can be set via `set -U`).
  - `fish_config theme save <theme_name>` will also update this file to store the selected theme.
- `~/functions/fish_prompt.fish` (can be re‑generated by `fish_config`, the built‑in fish config tool).
