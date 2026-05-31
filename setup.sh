#!/usr/bin/env bash
#
# Dotfiles setup: symlink home dotfiles into this repo.
#
# Layout:
#   dotfiles/.config/<name>/...  → ~/.config/<name>   (each subdir linked as a whole)
#   dotfiles/<group>/<file>      → ~/<file>           (each file linked individually)
#
# Usage:
#   ./setup.sh              interactive (default)
#   ./setup.sh -y, --yes    non-interactive; backup existing files automatically
#   ./setup.sh -n, --dry-run    show planned actions, change nothing
#   ./setup.sh -f, --force  overwrite existing files without backup
#   ./setup.sh -a, --all    link configs even if the tool's binary is not installed
#   ./setup.sh -h, --help   show this help

set -euo pipefail
shopt -s nullglob dotglob

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"

DRY_RUN=0
NON_INTERACTIVE=0
FORCE=0
LINK_ALL=0

print_help() {
  sed -n '2,/^set -euo/p' "$0" | sed '$d' | sed 's/^# \{0,1\}//;s/^#$//'
}

for arg in "$@"; do
  case "$arg" in
    -n|--dry-run) DRY_RUN=1 ;;
    -y|--yes)     NON_INTERACTIVE=1 ;;
    -f|--force)   FORCE=1 ;;
    -a|--all)     LINK_ALL=1 ;;
    -h|--help)    print_help; exit 0 ;;
    *) printf 'unknown arg: %s\n' "$arg" >&2; exit 2 ;;
  esac
done

if [ -t 1 ]; then
  RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[0;33m'
  BLUE=$'\033[0;34m'; BOLD=$'\033[1m'; DIM=$'\033[2m'; RESET=$'\033[0m'
else
  RED= GREEN= YELLOW= BLUE= BOLD= DIM= RESET=
fi

info() { printf '%s\n' "$*"; }
warn() { printf '%s%s%s\n' "$YELLOW" "$*" "$RESET" >&2; }
ok()   { printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$*"; }
miss() { printf '  %s✗%s %s\n' "$DIM" "$RESET" "$*"; }
skip() { printf '  %s•%s %s\n' "$DIM" "$RESET" "$*"; }

# ─────────────────────────────────────────────────────────────────────────────
# Tool detection table
#
# By default: folder name == binary name (no edit needed when adding new tool).
# Only declare exceptions below.
#
#   NO_BINARY:  folders linked unconditionally (no tool binary to detect).
#   BINARY_AS:  folders whose binary has a different name.  "<folder>=<binary>"
# ─────────────────────────────────────────────────────────────────────────────
NO_BINARY=(
  configarchive          # archive of old nvim config
)

BINARY_AS=(
  # example: code=code-insiders
)

contains() {
  local needle="$1"; shift
  local x
  for x in ${@+"$@"}; do [ "$x" = "$needle" ] && return 0; done
  return 1
}

binary_for() {
  local folder="$1" pair
  contains "$folder" ${NO_BINARY[@]+"${NO_BINARY[@]}"} && { printf ''; return; }
  for pair in ${BINARY_AS[@]+"${BINARY_AS[@]}"}; do
    case "$pair" in
      "$folder="*) printf '%s' "${pair#*=}"; return ;;
    esac
  done
  printf '%s' "$folder"
}

is_tool_installed() {
  local bin
  bin="$(binary_for "$1")"
  [ -z "$bin" ] && return 0
  command -v "$bin" >/dev/null 2>&1
}

# yes/no prompt; honors NON_INTERACTIVE (uses $default).
prompt_yn() {
  local prompt="$1" default="${2:-n}" hint reply
  if [ "$default" = "y" ]; then hint="[Y/n]"; else hint="[y/N]"; fi
  if [ "$NON_INTERACTIVE" -eq 1 ]; then
    [ "$default" = "y" ]
    return
  fi
  while :; do
    read -r -p "$prompt $hint " reply </dev/tty || reply=""
    reply="${reply:-$default}"
    case "$reply" in
      y|Y|yes|YES) return 0 ;;
      n|N|no|NO)   return 1 ;;
    esac
  done
}

# Build the plan as three parallel arrays.
PLAN_TARGET=()
PLAN_SOURCE=()
PLAN_TOOL=()

add_plan() {
  PLAN_TARGET+=("$1")
  PLAN_SOURCE+=("$2")
  PLAN_TOOL+=("$3")
}

# .config/* — each subdirectory becomes one symlink under ~/.config/<name>
if [ -d "$DOTFILES_DIR/.config" ]; then
  for src in "$DOTFILES_DIR/.config"/*; do
    [ -d "$src" ] || continue
    name="$(basename "$src")"
    add_plan "$HOME/.config/$name" "$src" "$name"
  done
fi

# Top-level groups (zsh/, vim/, ...) — each direct child becomes a home-level symlink
for grp in "$DOTFILES_DIR"/*; do
  [ -d "$grp" ] || continue
  name="$(basename "$grp")"
  case "$name" in
    .config|.git|.github) continue ;;
  esac
  for f in "$grp"/*; do
    [ -e "$f" ] || continue
    [ -d "$f" ] && continue   # only direct files, not nested dirs
    add_plan "$HOME/$(basename "$f")" "$f" "$name"
  done
done

if [ "${#PLAN_TARGET[@]}" -eq 0 ]; then
  warn "Nothing to link. Is the repo layout correct?"
  exit 0
fi

# Header
info "${BOLD}Dotfiles setup${RESET}"
info "  repo: $DOTFILES_DIR"
info "  mode: $([ $DRY_RUN -eq 1 ] && echo 'dry-run' || echo 'apply')"
echo

# Unique tools
unique_tools=()
for t in "${PLAN_TOOL[@]}"; do
  found=0
  for u in ${unique_tools[@]+"${unique_tools[@]}"}; do
    [ "$u" = "$t" ] && { found=1; break; }
  done
  [ $found -eq 0 ] && unique_tools+=("$t")
done

info "${BOLD}Detection${RESET}"
for t in "${unique_tools[@]}"; do
  if is_tool_installed "$t"; then
    ok "$t"
  else
    miss "$t (not installed)"
  fi
done
echo

# Render plan with short paths
short_home()    { printf '%s' "${1/#$HOME/~}"; }
short_source()  { printf '%s' "${1/#$DOTFILES_DIR/.}"; }

info "${BOLD}Plan${RESET}"
for i in "${!PLAN_TARGET[@]}"; do
  target="${PLAN_TARGET[$i]}"
  source="${PLAN_SOURCE[$i]}"
  tool="${PLAN_TOOL[$i]}"
  if [ "$LINK_ALL" -eq 1 ] || is_tool_installed "$tool"; then
    printf '  %s ← %s\n' "$(short_home "$target")" "$(short_source "$source")"
  else
    printf '  %s%s ← %s  (skip: %s not installed)%s\n' \
      "$DIM" "$(short_home "$target")" "$(short_source "$source")" "$tool" "$RESET"
  fi
done
echo

if [ "$DRY_RUN" -eq 1 ]; then
  info "${DIM}--dry-run; no changes made.${RESET}"
  exit 0
fi

if ! prompt_yn "Proceed?" y; then
  info "Aborted."
  exit 0
fi
echo

backup_path() { printf '%s.bak.%s' "$1" "$TIMESTAMP"; }

link_one() {
  local target="$1" source="$2" tool="$3"

  if [ "$LINK_ALL" -ne 1 ] && ! is_tool_installed "$tool"; then
    skip "$(short_home "$target") (skip: $tool not installed)"
    return
  fi

  if [ -L "$target" ]; then
    local current
    current="$(readlink "$target")"
    if [ "$current" = "$source" ]; then
      skip "$(short_home "$target") (already linked)"
      return
    fi
    if [ "$FORCE" -eq 1 ] || prompt_yn "  $(short_home "$target") points to $current. Replace?" n; then
      rm "$target"
    else
      skip "$(short_home "$target") (kept existing symlink)"
      return
    fi
  elif [ -e "$target" ]; then
    if [ "$FORCE" -eq 1 ]; then
      rm -rf "$target"
    else
      local bak; bak="$(backup_path "$target")"
      if prompt_yn "  $(short_home "$target") exists. Back up to $(basename "$bak") and replace?" y; then
        mv "$target" "$bak"
        info "    backed up: $(basename "$bak")"
      else
        skip "$(short_home "$target") (kept existing)"
        return
      fi
    fi
  fi

  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"
  ok "$(short_home "$target") → $(short_source "$source")"
}

errors=0
for i in "${!PLAN_TARGET[@]}"; do
  if ! link_one "${PLAN_TARGET[$i]}" "${PLAN_SOURCE[$i]}" "${PLAN_TOOL[$i]}"; then
    errors=$((errors + 1))
  fi
done

echo
if [ "$errors" -gt 0 ]; then
  warn "Done with $errors error(s)."
  exit 1
fi
info "${BOLD}Done.${RESET}"
