if status is-interactive
    set -l os (uname)
    
    # SSH Agent setup
    set -l bw_socks "$HOME/.bitwarden-ssh-agent.sock"
    test "$os" = Darwin
        and set bw_socks "$HOME/Library/Containers/com.bitwarden.desktop/Data/.bitwarden-ssh-agent.sock"
        or set -p bw_socks "$HOME/.var/app/com.bitwarden.desktop/data/.bitwarden-ssh-agent.sock"
    for sock in $bw_socks
        test -S "$sock"; and set -gx SSH_AUTH_SOCK "$sock"; and break
    end
    # Prefer forwarded SSH agent in SSH sessions
    if set -q SSH_TTY
        set -l forwarded_sock /run/user/1000/gnupg/S.gpg-agent.ssh
        if test -S "$forwarded_sock"
            set -gx SSH_AUTH_SOCK "$forwarded_sock"
        end
    end

    # Homebrew setup
    if test -f /opt/homebrew/bin/brew
        /opt/homebrew/bin/brew shellenv | source
        # Additional Homebrew installed utilities
        set -l gnubin $HOMEBREW_PREFIX/opt/make/libexec/gnubin
        set -l openjdk_home $HOMEBREW_PREFIX/opt/openjdk/libexec/openjdk.jdk/Contents/Home
        test -d $gnubin; and fish_add_path $gnubin
        test -d $openjdk_home; and set -gx JAVA_HOME $openjdk_home
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
