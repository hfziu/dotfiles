if status is-interactive
    # Bitwarden SSH Agent
    set -l bw_sock $HOME/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock
    test -S "$bw_sock"; and set -gx SSH_AUTH_SOCK "$bw_sock"

    # Homebrew setup
    if test -f /opt/homebrew/bin/brew
        /opt/homebrew/bin/brew shellenv | source
        # Additional Homebrew installed utilities
        set -l gnubin $HOMEBREW_PREFIX/opt/make/libexec/gnubin
        set -l openjdk_home $HOMEBREW_PREFIX/opt/openjdk/libexec/openjdk.jdk/Contents/Home
        test -d $gnubin; and fish_add_path $gnubin
        test -d $openjdk_home; and set -gx JAVA_HOME $openjdk_home
    end

    # Go environment
    command -q go; and not test -f "$HOME/Library/Application Support/go/env"; and begin
        go env -w GOPATH=$HOME/.local/go GOBIN=$HOME/.local/bin
    end

    # Rust - Fish-compatible cargo setup
    test -d $HOME/.cargo/bin; and fish_add_path $HOME/.cargo/bin
end
