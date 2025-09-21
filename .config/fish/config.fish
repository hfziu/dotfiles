if status is-interactive
    # Locale
    set -gx LC_CTYPE en_US.UTF-8
    set -gx LC_ALL en_US.UTF-8

    # Bitwarden SSH Agent
    set -l bw_sock $HOME/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock
    test -S "$bw_sock"; and set -gx SSH_AUTH_SOCK "$bw_sock"

    # Homebrew related PATHs added to $fish_user_paths
    set -gx HOMEBREW_PREFIX (test -d /opt/homebrew; and echo /opt/homebrew; or echo /usr/local)
    set -q HOMEBREW_PREFIX; and begin
        fish_add_path $HOMEBREW_PREFIX/{sbin,bin}
        set -l gnubin $HOMEBREW_PREFIX/opt/make/libexec/gnubin
        set -l openjdk_home $HOMEBREW_PREFIX/opt/openjdk/libexec/openjdk.jdk/Contents/Home
        test -d $gnubin; and fish_add_path $gnubin
        test -d $openjdk_home; and set -gx JAVA_HOME $openjdk_home
    end

    # Standard paths
    fish_add_path /usr/local/{sbin,bin} $HOME/.local/bin

    # Go environment
    command -q go; and not test -f "$HOME/Library/Application Support/go/env"; and begin
        go env -w GOPATH=$HOME/.local/go GOBIN=$HOME/.local/bin
    end

    # Rust - Fish-compatible cargo setup
    test -d $HOME/.cargo/bin; and fish_add_path $HOME/.cargo/bin

    # China (Mainland) mirrors - enabled by default
    # USTC mirrors for Homebrew, Rustup
    cn_mirrors on
end
