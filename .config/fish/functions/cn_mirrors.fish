function cn_mirrors
    set -l mirror "https://mirrors.ustc.edu.cn"
    
    switch $argv[1]
        case on enable set
            set -gx RUSTUP_UPDATE_ROOT "$mirror/rust-static/rustup"
            set -gx RUSTUP_DIST_SERVER "$mirror/rust-static"
            set -gx HOMEBREW_API_DOMAIN "$mirror/homebrew-bottles/api"
            set -gx HOMEBREW_BOTTLE_DOMAIN "$mirror/homebrew-bottles"
            set -gx HOMEBREW_BREW_GIT_REMOTE "$mirror/brew.git"
            set -gx HOMEBREW_CORE_GIT_REMOTE "$mirror/homebrew-core.git"
            set -gx HOMEBREW_PIP_INDEX_URL "$mirror/pypi/simple"
            
        case off disable unset
            set -e RUSTUP_UPDATE_ROOT RUSTUP_DIST_SERVER
            set -e HOMEBREW_API_DOMAIN HOMEBREW_BOTTLE_DOMAIN HOMEBREW_BREW_GIT_REMOTE HOMEBREW_CORE_GIT_REMOTE HOMEBREW_PIP_INDEX_URL
            
        case '*'
            echo "Usage: cn_mirrors [on|off]"
            echo "  on  - Enable China mirrors (USTC)"
            echo "  off - Disable China mirrors"
    end
end