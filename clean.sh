#!/usr/bin/env bash
#
# ============================================================================
# Dotfiles symlink クリーンスクリプト
# ============================================================================
#
# setup.sh が張ったシンボリックリンクを取り除きます。消すのはリンクだけで、
# 実体ファイルやリポジトリ本体には一切触れません。
# 「リンク先がこのリポジトリ配下を指す symlink」だけを対象にするので、
# 旧 .config / 新 config のどちらを指していても、またリンク切れでも消せます。
#
# 主な用途:
#   - 検証用 VM やマシンを setup.sh 実行前のまっさらな状態に戻す
#   - フォルダ名変更などで残ったリンク切れの掃除
#
# 使い方:
#   ./clean.sh              対話モード (削除前に一覧表示して確認)
#   ./clean.sh -n, --dry-run  消す予定だけ表示し、実際には消さない
#   ./clean.sh -y, --yes    確認なしで削除
#   ./clean.sh -h, --help   ヘルプを表示
# ============================================================================

set -euo pipefail
# nullglob : マッチ無しのワイルドカードを空に / dotglob : ドット始まりも拾う
shopt -s nullglob dotglob


# --- パス -------------------------------------------------------------------
# このスクリプト自身の場所 = dotfiles リポジトリの絶対パス
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"


# --- 実行モード -------------------------------------------------------------
DRY_RUN=0          # 1 なら何も削除しない
NON_INTERACTIVE=0  # 1 なら確認プロンプトを出さない


# --- ヘルプ表示 (setup.sh と同じ、冒頭コメントを流用する方式) ---------------
print_help() {
  awk 'NR > 1 {
         if (!/^#/) exit
         sub(/^# ?/, "")
         print
       }' "$0"
}


# --- 引数パース -------------------------------------------------------------
for arg in "$@"; do
  case "$arg" in
    -n|--dry-run) DRY_RUN=1 ;;
    -y|--yes)     NON_INTERACTIVE=1 ;;
    -h|--help)    print_help; exit 0 ;;
    *) printf 'unknown arg: %s\n' "$arg" >&2; exit 2 ;;
  esac
done


# --- 色・ログ (setup.sh と統一) ---------------------------------------------
if [ -t 1 ]; then
  RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[0;33m'
  BLUE=$'\033[0;34m'; BOLD=$'\033[1m'; DIM=$'\033[2m'; RESET=$'\033[0m'
else
  RED= GREEN= YELLOW= BLUE= BOLD= DIM= RESET=
fi

info() { printf '%s\n' "$*"; }
warn() { printf '%s%s%s\n' "$YELLOW" "$*" "$RESET" >&2; }
ok()   { printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$*"; }
skip() { printf '  %s•%s %s\n' "$DIM" "$RESET" "$*"; }

# ~/... 表記に短縮して見やすくする
short_home() { printf '%s' "${1/#$HOME/~}"; }

# 確認プロンプト ($1=メッセージ, $2=デフォルト y|n)
prompt_yn() {
  local msg="$1" def="${2:-n}" reply hint
  [ "$def" = y ] && hint="[Y/n]" || hint="[y/N]"
  printf '%s %s ' "$msg" "$hint"
  read -r reply || reply=""
  reply="${reply:-$def}"
  case "$reply" in [Yy]*) return 0 ;; *) return 1 ;; esac
}


# --- 削除対象の収集 ---------------------------------------------------------
# 走査する場所: ホーム直下 / ~/.config 直下 / ~/.claude 直下 の各エントリ。
# そのうち「symlink かつ リンク先が $DOTFILES_DIR/ で始まるもの」だけを拾う。
TARGETS=()
for p in "$HOME"/* "$HOME"/.config/* "$HOME"/.claude/*; do
  [ -L "$p" ] || continue                       # symlink でなければ対象外
  dest="$(readlink "$p")"                        # 切れたリンクでも readlink は読める
  case "$dest" in
    "$DOTFILES_DIR"/*) TARGETS+=("$p") ;;         # このリポジトリを指すものだけ
  esac
done


info "${BOLD}Dotfiles clean${RESET}"
info "  repo: $DOTFILES_DIR"
info "  mode: $([ $DRY_RUN -eq 1 ] && echo 'dry-run' || echo 'remove')"
echo

if [ "${#TARGETS[@]}" -eq 0 ]; then
  info "削除対象の symlink はありません。"
  exit 0
fi

# --- 一覧表示 ---------------------------------------------------------------
info "${BOLD}Plan${RESET}"
for t in "${TARGETS[@]}"; do
  status=$([ -e "$t" ] && echo "" || echo " ${DIM}(broken)${RESET}")
  printf '  rm %s %s→%s %s%s\n' "$(short_home "$t")" "$DIM" "$RESET" "$(readlink "$t")" "$status"
done
echo

# --- dry-run はここで終了 ---------------------------------------------------
if [ "$DRY_RUN" -eq 1 ]; then
  info "${DIM}--dry-run; no changes made.${RESET}"
  exit 0
fi

# --- 確認 -------------------------------------------------------------------
if [ "$NON_INTERACTIVE" -ne 1 ]; then
  if ! prompt_yn "Remove ${#TARGETS[@]} symlink(s)?" n; then
    info "Aborted."
    exit 0
  fi
  echo
fi

# --- 削除 -------------------------------------------------------------------
for t in "${TARGETS[@]}"; do
  rm "$t"
  ok "removed $(short_home "$t")"
done

echo
info "${GREEN}Done.${RESET} 再リンクは ./setup.sh で行えます。"
