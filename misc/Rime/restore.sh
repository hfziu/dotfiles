#!/usr/bin/env bash

# Define colors using ANSI escape codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Log function for consistent output formatting
log() {
    local action=$1
    local message=$2

    case "$action" in
        install)
            echo -e "  ${GREEN}[Installed]${NC} ${message}"
            ;;
        update)
            echo -e "  ${YELLOW}[Updated  ]${NC} ${message}"
            ;;
        skip)
            echo -e "  [Skipped  ] ${message}"
            ;;
        error)
            echo -e "${RED}Error: ${message}${NC}"
            ;;
    esac
}

# Detect OS type
OS_TYPE=$(uname -s)

# Check if the OS is Darwin (macOS)
if [ "$OS_TYPE" != "Darwin" ]; then
    echo "Current OS ($OS_TYPE) is not supported. This script only works on macOS (Darwin)."
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Target directory for Rime configuration
RIME_DIR="$HOME/Library/Rime"

# Check if the Rime directory exists
if [ ! -d "$RIME_DIR" ]; then
    log "error" "Rime directory ($RIME_DIR) does not exist."
    echo "Please install Rime first."
    exit 1
fi

# Copy all *.custom.yaml files to the Rime directory
for file in "$SCRIPT_DIR"/*.custom.yaml; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        target="$RIME_DIR/$filename"

        if [ -f "$target" ]; then
            # Check if files are identical
            if cmp -s "$file" "$target"; then
                log "skip" "$filename"
            else
                cp "$file" "$target"
                log "update" "$filename"
            fi
        else
            cp "$file" "$target"
            log "install" "$filename"
        fi
    fi
done
