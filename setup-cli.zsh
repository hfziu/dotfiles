#!/usr/bin/env zsh

# Only enable strict mode when executed directly, not when sourced
(( ${zsh_eval_context[(I)file]} )) || set -euo pipefail

readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly OS="$(uname -s)"
readonly OS_LOWER="${OS:l}"

BACKUP_DIR=""

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly GRAY='\033[0;37m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# --- Helpers ---

_print_action() {
  local action="$1" color="$2"; shift 2
  printf "  ${color}[%-7s]${NC} %b\n" "$action" "$*" >&2
}

_log() {
  local level="$1"; shift
  local -A labels=([info]="INFO" [warn]="WARN" [error]="ERROR" [success]="SUCCESS")
  local -A colors=([info]="$CYAN" [warn]="$YELLOW" [error]="$RED" [success]="$GREEN")
  printf "${colors[$level]}[${BOLD}%s${NC}${colors[$level]}]${NC} " "${labels[$level]}" >&2
  printf "%b\n" "$*" >&2
}

_section() {
  local name="$1" cmd="${2:-}"
  if [[ -n "$cmd" ]] && ! _has_command "$cmd"; then
    printf "  ${BOLD}${YELLOW}==== %s (%s not found, skipping) ====${NC}\n" "$name" "$cmd" >&2
    return 1
  fi
  printf "  ${BOLD}${BLUE}==== %s ====${NC}\n" "$name" >&2
}

_validate_os() {
  if [[ "${OS}" != "Darwin" && "${OS}" != "Linux" ]]; then
    _log error "Unknown OS: ${OS}. Only macOS (Darwin) and Linux are supported."
    exit 1
  fi
}

_backup() {
  local file="$1"
  [[ -z "$BACKUP_DIR" ]] && BACKUP_DIR="$(mktemp -d)"

  local rel="${file#${HOME}/}"
  [[ "$rel" == "$file" ]] && rel="_${file}"

  mkdir -p "$(dirname "${BACKUP_DIR}/${rel}")"
  cp "$file" "${BACKUP_DIR}/${rel}"
}

_safe_copy() {
  local src="$1" dest="$2"
  [[ ! -f "$src" ]] && { _log warn "Source file not found: $src"; return 0; }

  local display="${dest/#${HOME}/~}"
  if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
    _print_action "SKIP" "$GRAY" "$display"
  elif [[ -f "$dest" ]]; then
    _backup "$dest"
    cp "$src" "$dest"
    _print_action "UPDATE" "$YELLOW" "$display"
  else
    cp "$src" "$dest"
    _print_action "CREATE" "$GREEN" "$display"
  fi
}

_has_command() {
  (( $+commands[$1] ))
}

_generate_zsh_completion() {
  local dest_name="$1"; shift
  local zfunc_dir="${HOME}/.zfunc"
  local temp_dir="$(mktemp -d)"
  mkdir -p "$zfunc_dir"

  {
    "$@" >| "${temp_dir}/${dest_name}"
    _safe_copy "${temp_dir}/${dest_name}" "${zfunc_dir}/${dest_name}"
    local -a dumps=( "${XDG_CACHE_HOME:-${HOME}/.cache}/zsh"/.zcompdump-*(N) )
    if (( ${#dumps} )); then rm -f -- "${dumps[@]}"; fi
  } always {
    rm -rf "$temp_dir"
  }
}

_generate_completion_if_available() {
  local exe="$1" dest="$2"; shift 2
  if ! _has_command "$exe"; then
    _print_action "SKIP" "$GRAY" "$exe not found; skipped zsh completion"
    return 1
  fi
  _generate_zsh_completion "$dest" "$@"
}

_configure_git_user() {
  local username email
  read "username?Git Username: "
  read "email?Git Email: "

  [[ -n "$username" ]] && git config --global user.name "$username"
  [[ -n "$email" ]] && git config --global user.email "$email"
}

_restore_git_config() {
  local username email
  while (( $# >= 2 )); do
    local key="$1" value="$2"
    case "$key" in
      "user.name") username="$value" ;;
      "user.email") email="$value" ;;
    esac
    [[ -n "$value" ]] && git config --global "$key" "$value"
    shift 2
  done
  _print_action "RESTORE" "$GREEN" "Git user: ${BOLD}${username}${NC} <${email}>"
}

_print_backup_summary() {
  [[ -z "$BACKUP_DIR" ]] && return 0
  local display="$BACKUP_DIR"
  [[ -n "${TMPDIR:-}" && "$display" == "${TMPDIR}"* ]] && display="\$TMPDIR/${display#${TMPDIR}}"
  _log info "Backup files saved in: ${BOLD}${display}${NC}"
}

# Setup steps

setup_profile() {
  _section "Profile"
  _safe_copy "${SCRIPT_DIR}/.profile" "${HOME}/.profile"
}

setup_antidote() {
  _section "Antidote"
  local antidote_home="${ZDOTDIR:-$HOME}/.antidote"
  if [[ -r "${antidote_home}/antidote.zsh" ]]; then
    _print_action "SKIP" "$GRAY" "${antidote_home/#${HOME}/~}/antidote.zsh"
    return 0
  fi
  _has_command git || { _log error "git is required to install antidote."; exit 1; }
  _log info "Installing antidote from the official git repository"
  git clone --depth=1 https://github.com/mattmc3/antidote.git "$antidote_home"
}

setup_zsh() {
  _section "Zsh"
  _safe_copy "${SCRIPT_DIR}/zsh/zshrc.basic.zsh" "${HOME}/.zshrc.basic.zsh"
  _safe_copy "${SCRIPT_DIR}/zsh/zsh_plugins.txt" "${HOME}/.zsh_plugins.txt"
  _safe_copy "${SCRIPT_DIR}/zsh/functions.zsh" "${HOME}/.functions.zsh"
  _safe_copy "${SCRIPT_DIR}/zsh/zshrc.${OS_LOWER}.zsh" "${HOME}/.zshrc"
  _safe_copy "${SCRIPT_DIR}/zsh/zshenv.${OS_LOWER}.zsh" "${HOME}/.zshenv"
}

setup_completions() {
  _section "Completions"

  # uv + uvx
  if _generate_completion_if_available "uv" "_uv" uv generate-shell-completion zsh; then
    _generate_completion_if_available "uvx" "_uvx" uvx --generate-shell-completion zsh || true
  fi

  # mise
  if _generate_completion_if_available "mise" "_mise" mise completion zsh; then
    _has_command usage || _print_action "WARN" "$YELLOW" "Install usage for mise completions to work"
  fi

  # docker
  _generate_completion_if_available "docker" "_docker" docker completion zsh || true
}

setup_starship() {
  _section "Starship" "starship" || return 0
  mkdir -p "${HOME}/.config"
  _safe_copy "${SCRIPT_DIR}/starship/starship.toml" "${HOME}/.config/starship.toml"
}

setup_vim() {
  _section "Vim" "vim" || return 0
  _safe_copy "${SCRIPT_DIR}/vim/.vimrc" "${HOME}/.vimrc"
  _safe_copy "${SCRIPT_DIR}/vim/.basic.vimrc" "${HOME}/.basic.vimrc"
  _safe_copy "${SCRIPT_DIR}/vim/.plug.vimrc" "${HOME}/.plug.vimrc"
}

setup_ghostty() {
  _section "Ghostty" "ghostty" || return 0
  local config_dir="${HOME}/.config/ghostty"
  mkdir -p "$config_dir"
  _safe_copy "${SCRIPT_DIR}/ghostty/config" "${config_dir}/config"
  _safe_copy "${SCRIPT_DIR}/ghostty/config.${OS_LOWER}" "${config_dir}/config.${OS_LOWER}"
}

setup_fish() {
  _section "Fish" "fish" || return 0
  local config_dir="${HOME}/.config/fish"
  mkdir -p "$config_dir"
  _safe_copy "${SCRIPT_DIR}/fish/config.fish" "${config_dir}/config.fish"
}

setup_zellij() {
  _section "Zellij" "zellij" || return 0
  local config_dir="${HOME}/.config/zellij"
  local source_layout_dir="${SCRIPT_DIR}/misc/zellij/layouts"
  local target_layout_dir="${config_dir}/layouts"
  local layout
  mkdir -p "$config_dir"
  _safe_copy "${SCRIPT_DIR}/misc/zellij/config.kdl" "${config_dir}/config.kdl"

  [[ -d "$source_layout_dir" ]] || return 0
  mkdir -p "$target_layout_dir"
  for layout in "${source_layout_dir}"/*(N.); do
    _safe_copy "$layout" "${target_layout_dir}/${layout:t}"
  done
}

setup_tmux() {
  _section "Tmux" "tmux" || return 0
  _safe_copy "${SCRIPT_DIR}/.tmux.conf" "${HOME}/.tmux.conf"
}

setup_git() {
  _section "Git" "git" || return 0

  local -A git_config=(
    ["user.name"]="$(git config --global user.name 2>/dev/null || true)"
    ["user.email"]="$(git config --global user.email 2>/dev/null || true)"
    ["user.signingkey"]="$(git config --global user.signingkey 2>/dev/null || true)"
    ["credential.helper"]="$(git config --global credential.helper 2>/dev/null || true)"
    ["commit.gpgsign"]="$(git config --global commit.gpgsign 2>/dev/null || true)"
  )

  _safe_copy "${SCRIPT_DIR}/git/.gitignore_global" "${HOME}/.gitignore_global"
  _safe_copy "${SCRIPT_DIR}/git/.gitconfig" "${HOME}/.gitconfig"

  if [[ -z "${git_config[user.name]}" ]]; then
    _configure_git_user
  else
    _restore_git_config "${(@kv)git_config}"
  fi
}

# --- Main ---

main() {
  _validate_os
  _log info "Starting dotfiles setup for ${BOLD}${OS}${NC}"

  setup_profile

  # Shell
  setup_antidote
  setup_zsh
  setup_completions
  setup_starship

  # Apps
  setup_vim
  setup_ghostty
  setup_fish
  setup_zellij
  setup_tmux

  # Git
  setup_git

  _print_backup_summary
  _log success "Dotfiles setup completed successfully!"
}

(( ${zsh_eval_context[(I)file]} )) || main "$@"
