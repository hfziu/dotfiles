if status is-interactive
    set -l os (uname)

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

    # Local path
    test -d $HOME/.local/bin; and fish_add_path $HOME/.local/bin

    # Python, uv
    set -x UV_TORCH_BACKEND auto

    # Go environment
    command -q go; and not test -f (go env GOENV); and begin
        go env -w GOPATH=$HOME/.local/go GOBIN=$HOME/.local/bin
    end

    # Rust - Fish-compatible cargo setup
    test -d $HOME/.cargo/bin; and fish_add_path $HOME/.cargo/bin
end
