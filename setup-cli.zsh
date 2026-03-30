#!/usr/bin/env zsh

# Only enable strict mode when executed directly, not when sourced
(( ${zsh_eval_context[(I)file]} )) || set -euo pipefail

# Script metadata
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly OS="$(uname -s)"
readonly OS_LOWER="${OS:l}"

# Backup state
BACKUP_DIR=""
HAS_UPDATES=false

# Terminal colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly GRAY='\033[0;37m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Internal helpers

_format_action() {
  local action="$1" color="$2"

  printf "${color}[%-7s]${NC}" "$action"
}

_log() {
  local level="$1"; shift

  local -A levels=([info]="INFO" [warn]="WARN" [error]="ERROR" [success]="SUCCESS")
  local -A colors=([info]="$CYAN" [warn]="$YELLOW" [error]="$RED" [success]="$GREEN")

  local label="${levels[$level]:-LOG}"
  local color="${colors[$level]:-}"
  printf "${color}[${BOLD}%s${NC}${color}]${NC} " "$label" >&2
  printf "%b\n" "$*" >&2
}

_section() {
  local section_name="$1"
  local command_name="${2:-}"

  if [[ -n "$command_name" ]]; then
    if (( ! $+commands[$command_name] )); then
      printf "  ${BOLD}${YELLOW}==== %s (%s not found, skipping) ====${NC}\n" "$section_name" "$command_name" >&2
      return 1
    fi
  fi

  printf "  ${BOLD}${BLUE}==== %s ====${NC}\n" "$section_name" >&2
  return 0
}

_validate_os() {
  if [[ "${OS}" != "Darwin" && "${OS}" != "Linux" ]]; then
    _log error "Unknown OS: ${OS}. Only macOS (Darwin) and Linux are supported."
    exit 1
  fi
}

_backup() {
  local file_to_backup="$1"

  if [[ "$HAS_UPDATES" != true ]]; then
    HAS_UPDATES=true
    if [[ -z "$BACKUP_DIR" ]]; then
      BACKUP_DIR="$(mktemp -d)"
    fi
  fi

  local relative_path="${file_to_backup#${HOME}/}"
  if [[ "$relative_path" == "$file_to_backup" ]]; then
    relative_path="_${file_to_backup}"
  fi

  local backup_path="${BACKUP_DIR}/${relative_path}"
  local backup_dir="$(dirname "$backup_path")"

  mkdir -p "$backup_dir"

  cp "$file_to_backup" "$backup_path"
}

_safe_copy() {
  local src="$1" dest="$2"

  [[ ! -f "$src" ]] && { _log warn "Source file not found: $src"; return 0; }

  local action color

  if [[ -f "$dest" ]] && cmp -s "$src" "$dest"; then
    action="SKIP"
    color="$GRAY"
  elif [[ -f "$dest" ]]; then
    action="UPDATE"
    color="$YELLOW"
    _backup "$dest"
    cp "$src" "$dest"
  else
    action="CREATE"
    color="$GREEN"
    cp "$src" "$dest"
  fi

  local display_path="${dest/#${HOME}/~}"
  echo -e "  $(_format_action "$action" "$color") $display_path" >&2
}

_generate_zsh_completion() {
  local dest_name="$1"
  shift

  local zfunc_dir="${HOME}/.zfunc"
  local temp_dir output_file
  local -a compdump_files
  temp_dir="$(mktemp -d)"
  output_file="${temp_dir}/${dest_name}"
  mkdir -p "$zfunc_dir"

  "$@" >| "$output_file"
  _safe_copy "$output_file" "${zfunc_dir}/${dest_name}"
  compdump_files=( "${XDG_CACHE_HOME:-${HOME}/.cache}/zsh"/.zcompdump-*(N) )
  (( ${#compdump_files} )) && rm -f -- "${compdump_files[@]}"

  rm -rf "$temp_dir"
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

  echo -e "  $(_format_action "RESTORE" "$GREEN") Git user: ${BOLD}${username}${NC} <${email}>" >&2
}

_print_backup_summary() {
  if $HAS_UPDATES && [[ -n "$BACKUP_DIR" ]]; then
    if [[ -n "${TMPDIR:-}" && "$BACKUP_DIR" == "${TMPDIR}"* ]]; then
      BACKUP_DIR="\$TMPDIR/${BACKUP_DIR#${TMPDIR}}"
    fi
    _log info "Backup files saved in: ${BOLD}$BACKUP_DIR${NC}"
  fi
}

# Setup steps

setup_profile() {
  _section "Profile"
  _safe_copy "${SCRIPT_DIR}/.profile" "${HOME}/.profile"
}

setup_antidote() {
  _section "Antidote"

  local antidote_home="${ZDOTDIR:-$HOME}/.antidote"
  local antidote_source="${antidote_home}/antidote.zsh"

  if [[ -r "$antidote_source" ]]; then
    echo -e "  $(_format_action "SKIP" "$GRAY") ${antidote_source/#${HOME}/~}" >&2
    return 0
  fi

  (( $+commands[git] )) || { _log error "git is required to install antidote."; exit 1; }

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

setup_uv_completions() {
  _section "uv Completions"
  if (( ! $+commands[uv] )); then
    echo -e "  $(_format_action "SKIP" "$GRAY") Install uv manually to generate its zsh completions" >&2
    return 0
  fi

  _generate_zsh_completion "_uv" uv generate-shell-completion zsh

  if (( $+commands[uvx] )); then
    _generate_zsh_completion "_uvx" uvx --generate-shell-completion zsh
  else
    echo -e "  $(_format_action "SKIP" "$GRAY") uvx not found; skipped its zsh completion" >&2
  fi
}

setup_mise_completions() {
  _section "Mise Completions"
  if (( ! $+commands[mise] )); then
    echo -e "  $(_format_action "SKIP" "$GRAY") Install mise manually to generate its zsh completions" >&2
    return 0
  fi

  _generate_zsh_completion "_mise" mise completion zsh

  if (( ! $+commands[usage] )); then
    echo -e "  $(_format_action "WARN" "$YELLOW") Install usage manually for mise completions to work" >&2
  fi
}

setup_starship() {
  _section "Starship"
  if (( ! $+commands[starship] )); then
    echo -e "  $(_format_action "SKIP" "$GRAY") Install starship manually to use this prompt config" >&2
    return 0
  fi

  local config_dir="${HOME}/.config"
  mkdir -p "$config_dir"
  _safe_copy "${SCRIPT_DIR}/starship/starship.toml" "${config_dir}/starship.toml"
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

setup_tmux() {
  _section "Tmux" "tmux" || return 0
  _safe_copy "${SCRIPT_DIR}/.tmux.conf" "${HOME}/.tmux.conf"
}

setup_shell() {
  setup_antidote
  setup_zsh
  setup_uv_completions
  setup_mise_completions
  setup_starship
}

setup_apps() {
  setup_vim
  setup_ghostty
  setup_fish
  setup_tmux
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

# Main execution
main() {
  _validate_os
  _log info "Starting dotfiles setup for" "${BOLD}${OS}${NC}"

  setup_profile
  setup_shell
  setup_apps
  setup_git

  _print_backup_summary
  _log success "Dotfiles setup completed successfully!"
}

# Run main function if script is executed directly
(( ${zsh_eval_context[(I)file]} )) || main "$@"
