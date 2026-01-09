if status is-interactive
    set -l os (uname)

    
    # SSH Agent setup - only configure if not in an SSH session
    if not set -q SSH_TTY; and not set -q SSH_CONNECTION
        if test "$os" = Darwin
            # macOS - Check for Bitwarden SSH Agent
            set -l bw_sock "$HOME/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock"
            test -S "$bw_sock"; and set -gx SSH_AUTH_SOCK "$bw_sock"
        else
            # Linux - Try Bitwarden (flatpak or native) first, fallback to systemd socket
            set -l systemd_sock "$XDG_RUNTIME_DIR/ssh-agent.socket"
            set -l bw_flatpak "$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock"
            set -l bw_native "$HOME/.bitwarden-ssh-agent.sock"
            
            if test -S "$bw_flatpak"
                set -gx SSH_AUTH_SOCK "$bw_flatpak"
            else if test -S "$bw_native"
                set -gx SSH_AUTH_SOCK "$bw_native"
            else if test -S "$systemd_sock"
                set -gx SSH_AUTH_SOCK "$systemd_sock"
            end
        end
    end

    # Homebrew setup
    if test "$os" = Darwin; and test -f /opt/homebrew/bin/brew
        # `brew shellenv` generates environment setup commands for a specific
        # shell based on $SHELL. Since I'm not using fish as my default login
        # shell, I temporarily set $SHELL to fish for this command. Otherwise
        # the output of `brew shellenv` would not be fish-compatible.
        env SHELL=(status fish-path) /opt/homebrew/bin/brew shellenv | source
        # Additional Homebrew installed utilities
        set -l gnubin $HOMEBREW_PREFIX/opt/make/libexec/gnubin
        set -l openjdk_home $HOMEBREW_PREFIX/opt/openjdk/libexec/openjdk.jdk/Contents/Home
        test -d $gnubin; and fish_add_path $gnubin
        test -d $openjdk_home; and set -gx JAVA_HOME $openjdk_home
    else if test -f /home/linuxbrew/.linuxbrew/bin/brew
        # Do nothing; Some Linuxbrew setups already have /etc/profile.d/brew.sh
        # to setup the environment.
    end

    # Python, uv
    set -x UV_TORCH_BACKEND auto

    # Go environment
    command -q go; and not test -f "$HOME/Library/Application Support/go/env"; and begin
        go env -w GOPATH=$HOME/.local/go GOBIN=$HOME/.local/bin
    end

    # Rust - Fish-compatible cargo setup
    test -d $HOME/.cargo/bin; and fish_add_path $HOME/.cargo/bin
end
