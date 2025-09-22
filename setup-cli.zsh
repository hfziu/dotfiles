#!/usr/bin/env zsh

# Only enable strict mode when executed directly, not when sourced
(( ${zsh_eval_context[(I)file]} )) || set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly OS="$(uname -s)"
readonly OS_LOWER="${OS:l}"

# Global variables for backup functionality
BACKUP_DIR=""
HAS_UPDATES=false

# Color codes
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly GRAY='\033[0;37m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

format_action() {
  local action="$1" color="$2"
  
  # Pad the action text to 8 characters (10 total - 2 for brackets)
  # Use left-aligned padding with spaces inside the brackets
  printf "${color}[%-7s]${NC}" "$action"
}

log() {
  local level="$1"; shift
  
  local -A levels=([info]="INFO" [warn]="WARN" [error]="ERROR" [success]="SUCCESS")
  local -A colors=([info]="$CYAN" [warn]="$YELLOW" [error]="$RED" [success]="$GREEN")
  
  local label="${levels[$level]:-LOG}"
  local color="${colors[$level]:-}"
  printf "${color}[${BOLD}%s${NC}${color}]${NC} " "$label" >&2
  printf "%b\n" "$*" >&2
}

section() {
  local section_name="$1"
  local command_name="${2:-}"
  
  # If a command name is provided, check if it exists
  if [[ -n "$command_name" ]]; then
    if (( ! $+commands[$command_name] )); then
      printf "  ${BOLD}${YELLOW}==== %s (%s not found, skipping) ====${NC}\n" "$section_name" "$command_name" >&2
      return 1
    fi
  fi
  
  printf "  ${BOLD}${BLUE}==== %s ====${NC}\n" "$section_name" >&2
  return 0
}

validate_os() {
  if [[ "${OS}" != "Darwin" && "${OS}" != "Linux" ]]; then
    log error "Unknown OS: ${OS}. Only macOS (Darwin) and Linux are supported."
    exit 1
  fi
}

# Backup a file before overwriting it
backup() {
  local file_to_backup="$1"
  
  if [[ "$HAS_UPDATES" != true ]]; then
    HAS_UPDATES=true
    if [[ -z "$BACKUP_DIR" ]]; then
      BACKUP_DIR="$(mktemp -d)"
    fi
  fi
  
  # Calculate relative path from HOME directory
  local relative_path="${file_to_backup#${HOME}/}"
  
  # For files outside of HOME, back them up to ${BACKUP_DIR}/_/<absolute_path> using their absolute path structure.
  # NOTE: As of August 2025, this repository does not include any files intended for locations outside of HOME.
  if [[ "$relative_path" == "$file_to_backup" ]]; then
    relative_path="_${file_to_backup}"
  fi
  
  local backup_path="${BACKUP_DIR}/${relative_path}"
  local backup_dir="$(dirname "$backup_path")"
  
  mkdir -p "$backup_dir"
  
  cp "$file_to_backup" "$backup_path"
}

safe_copy() {
  local src="$1" dest="$2"
  
  [[ ! -f "$src" ]] && { log warn "Source file not found: $src"; return 0; }
  
  local action color
  
  if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
    action="SKIP"
    color="$GRAY"
  elif [[ -f "$dest" ]]; then
    action="UPDATE"
    color="$YELLOW"
    backup "$dest"
    cp "$src" "$dest"
  else
    action="CREATE"
    color="$GREEN"
    cp "$src" "$dest"
  fi
  
  local display_path="${dest/#${HOME}/~}"
  echo -e "  $(format_action "$action" "$color") $display_path" >&2
}

# Copy configuration files
setup_zsh() {
  section "Zsh"
  safe_copy "${SCRIPT_DIR}/zsh/zshrc.basic.zsh" "${HOME}/.zshrc.basic.zsh"
  safe_copy "${SCRIPT_DIR}/zsh/functions.zsh" "${HOME}/.functions.zsh"
  safe_copy "${SCRIPT_DIR}/zsh/zshrc.${OS_LOWER}.zsh" "${HOME}/.zshrc"
  safe_copy "${SCRIPT_DIR}/zsh/zshenv.${OS_LOWER}.zsh" "${HOME}/.zshenv"
}

setup_vim() {
  section "Vim" "vim" || return 0
  safe_copy "${SCRIPT_DIR}/vim/.vimrc" "${HOME}/.vimrc"
  safe_copy "${SCRIPT_DIR}/vim/.basic.vimrc" "${HOME}/.basic.vimrc"
  safe_copy "${SCRIPT_DIR}/vim/.plug.vimrc" "${HOME}/.plug.vimrc"
}

setup_ghostty() {
  section "Ghostty" "ghostty" || return 0
  local config_dir="${HOME}/.config/ghostty"
  mkdir -p "$config_dir"
  safe_copy "${SCRIPT_DIR}/ghostty/config" "${config_dir}/config"
  safe_copy "${SCRIPT_DIR}/ghostty/config.${OS_LOWER}" "${config_dir}/config.${OS_LOWER}"
}

setup_fish() {
  section "Fish" "fish" || return 0
  local config_dir="${HOME}/.config/fish"
  mkdir -p "$config_dir"
  safe_copy "${SCRIPT_DIR}/fish/config.fish" "${config_dir}/config.fish"
  # TODO: custom functions won't be automatically copied yet
}

setup_tmux() {
  section "Tmux" "tmux" || return 0
  safe_copy "${SCRIPT_DIR}/.tmux.conf" "${HOME}/.tmux.conf"
}

setup_git() {
  section "Git" "git" || return 0
  
  # Backup existing git config values using actual config keys
  local -A git_config=(
    ["user.name"]="$(git config --global user.name 2>/dev/null || true)"
    ["user.email"]="$(git config --global user.email 2>/dev/null || true)"
    ["user.signingkey"]="$(git config --global user.signingkey 2>/dev/null || true)"
    ["credential.helper"]="$(git config --global credential.helper 2>/dev/null || true)"
    ["commit.gpgsign"]="$(git config --global commit.gpgsign 2>/dev/null || true)"
  )
  
  # Copy git configuration files
  safe_copy "${SCRIPT_DIR}/git/.gitignore_global" "${HOME}/.gitignore_global"
  safe_copy "${SCRIPT_DIR}/git/.gitconfig" "${HOME}/.gitconfig"
  
  # Restore or configure git user info
  if [[ -z "${git_config[user.name]}" ]]; then
    configure_git_user
  else
    restore_git_config ${(kv)git_config}
  fi
}

configure_git_user() {
  local username email
  read "username?Git Username: "
  read "email?Git Email: "
  
  [[ -n "$username" ]] && git config --global user.name "$username"
  [[ -n "$email" ]] && git config --global user.email "$email"
}

restore_git_config() {
  local username email
  
  while (( $# >= 2 )); do
    local key="$1" value="$2"
    
    # Store display values
    case "$key" in
      "user.name") username="$value" ;;
      "user.email") email="$value" ;;
    esac
    
    # Set git config if value is not empty
    [[ -n "$value" ]] && git config --global "$key" "$value"
    shift 2
  done
  
  echo -e "  $(format_action "RESTORE" "$GREEN") Git user: ${BOLD}${username}${NC} <${email}>" >&2
}

# Main execution
main() {
  validate_os
  log info "Starting dotfiles setup for" "${BOLD}${OS}${NC}"
  
  setup_zsh
  setup_vim
  setup_ghostty
  setup_fish
  setup_tmux
  setup_git
    
  # Print backup directory location if any files were updated
  if $HAS_UPDATES && [[ -n "$BACKUP_DIR" ]]; then
    if [[ -n "${TMPDIR:-}" && "$BACKUP_DIR" == "${TMPDIR}"* ]]; then
      BACKUP_DIR="\$TMPDIR/${BACKUP_DIR#${TMPDIR}}"
    fi
    log info "Backup files saved in: ${BOLD}$BACKUP_DIR${NC}"
  fi
  log success "Dotfiles setup completed successfully!"
}

# Run main function if script is executed directly
(( ${zsh_eval_context[(I)file]} )) || main "$@"
