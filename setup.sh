#!/usr/bin/env bash
#
# ============================================================================
# Dotfiles セットアップスクリプト
# ============================================================================
#
# このリポジトリの dotfiles を $HOME 配下にシンボリックリンクで配置します。
#
# リンク規則:
#   dotfiles/config/<name>/...  →  ~/.config/<name>   (サブディレクトリ単位でリンク)
#   dotfiles/<group>/<file>      →  ~/<file>           (グループ配下の各ファイル単位でリンク)
#
# 使い方:
#   ./setup.sh              対話モード (デフォルト)
#   ./setup.sh -y, --yes    対話なし。既存ファイルは自動でバックアップして置換
#   ./setup.sh -n, --dry-run  予定だけ表示し、実際には何も変更しない
#   ./setup.sh -f, --force  既存ファイルをバックアップせずに上書き
#   ./setup.sh -a, --all    バイナリ未導入のツールもリンクする
#   ./setup.sh -h, --help   ヘルプを表示
# ============================================================================

# --- シェルの動作モード -----------------------------------------------------
# set -e          : 途中でコマンドが失敗したら即座にスクリプトを停止
# set -u          : 未定義の変数を参照したらエラーで停止 (タイポ防止)
# set -o pipefail : パイプライン中のどこかで失敗したら全体を失敗とみなす
set -euo pipefail

# shopt は bash の挙動を変えるオプション
#   nullglob : ワイルドカード (例: foo/*) が何にもマッチしなかったとき、
#              文字列 "foo/*" のまま渡さず空にする (for ループが空回りする)
#   dotglob  : ワイルドカードでドットから始まるファイル (.zshrc 等) も拾う
shopt -s nullglob dotglob


# --- パス・タイムスタンプ ---------------------------------------------------
# BASH_SOURCE[0] は「このスクリプト自身」のパス。それを dirname → cd → pwd と
# 経由することで、どこから呼び出されても dotfiles リポジトリの絶対パスを得る。
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# バックアップファイル名に使う、実行時のタイムスタンプ (例: 20260531-164500)
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"


# --- 実行モード (コマンドライン引数で切り替え) -----------------------------
DRY_RUN=0          # 1 なら何も変更しない
NON_INTERACTIVE=0  # 1 なら確認プロンプトを出さない
FORCE=0            # 1 なら既存ファイルをバックアップせず上書き
LINK_ALL=0         # 1 ならバイナリ未導入でもリンクする


# --- ヘルプ表示 -------------------------------------------------------------
# このファイル冒頭のコメントブロック (2行目から最初の空行まで) を抜き出して
# 表示する。ヘルプを別ファイルで管理せず済む簡易な仕組み。
print_help() {
  awk 'NR > 1 {
         if (!/^#/) exit       # コメント以外の行に当たったら終了
         sub(/^# ?/, "")       # 行頭の "# " を取り除いて表示
         print
       }' "$0"
}


# --- コマンドライン引数のパース ---------------------------------------------
# "$@" はスクリプトに渡された全引数。1つずつ見て、対応するフラグを立てる。
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


# --- ターミナル出力の色 -----------------------------------------------------
# [ -t 1 ] は「標準出力が端末に接続されているか」を判定する。
# パイプやリダイレクトされている場合は色を付けないようにすると、ログが綺麗になる。
if [ -t 1 ]; then
  RED=$'\033[0;31m'; GREEN=$'\033[0;32m'; YELLOW=$'\033[0;33m'
  BLUE=$'\033[0;34m'; BOLD=$'\033[1m'; DIM=$'\033[2m'; RESET=$'\033[0m'
else
  # 端末でないときは空文字を入れて、結果として色コードが出力されないようにする
  RED= GREEN= YELLOW= BLUE= BOLD= DIM= RESET=
fi


# --- ログ出力用の簡易関数 ---------------------------------------------------
# printf は echo よりも移植性が高く、改行や書式を厳密に扱える。
# "$*" は引数全部を1つのスペース区切り文字列としてまとめる記法。
info() { printf '%s\n' "$*"; }                              # 通常メッセージ
warn() { printf '%s%s%s\n' "$YELLOW" "$*" "$RESET" >&2; }   # 警告 (黄色 + stderr)
ok()   { printf '  %s✓%s %s\n' "$GREEN" "$RESET" "$*"; }    # 成功
miss() { printf '  %s✗%s %s\n' "$DIM" "$RESET" "$*"; }      # 未検出
skip() { printf '  %s•%s %s\n' "$DIM" "$RESET" "$*"; }      # スキップ


# ============================================================================
# 設定テーブル (新しいツールを追加するときはここを編集する)
# ============================================================================
#
# 大前提:
#   dotfiles/config/<フォルダ名>/ をそのまま ~/.config/<フォルダ名> へリンクする。
#   フォルダ名 == 実行コマンド名 (例: nvim フォルダ → nvim コマンド) であれば、
#   下の配列は何も編集しなくて良い。フォルダを置くだけで自動で拾う。
#
# 例外を扱いたいときだけ、以下の配列に追記する:
#
#   NO_BINARY    : フォルダ名に対応するバイナリが無い。常にリンク対象になる。
#
#   BINARY_AS    : フォルダ名とバイナリ名が違う。書式: "フォルダ名=バイナリ名"
#                  例: "vscode=code-insiders"
#
#   LINK_TO_HOME : フォルダ「全体」を ~/.config/<name> にリンクするのではなく、
#                  フォルダ内の各ファイルを ~/<ファイル名> へ個別にリンクする。
#                  zsh / vim のように、本来ホーム直下に置くべき設定をリポジトリ
#                  上は config/ 配下に集約したい場合に使う。
#
#   LINK_TO_SUBDIR : フォルダ内の各ファイルを ~/<別ディレクトリ>/<ファイル名> へ
#                  個別にリンクする。書式: "フォルダ名=ホーム配下のディレクトリ名"
#                  ツールが ~/.config ではなく独自ディレクトリを読む場合に使う。
#                  (履歴・認証等が同居するディレクトリ全体ではなく自作ファイルだけ
#                   リンクしたいケース。nix/common.nix の home.file と挙動を揃える)
# ============================================================================

NO_BINARY=(
  configarchive          # 旧 nvim 設定のアーカイブ。対応するツール無し
)

BINARY_AS=(
  # 例: code=code-insiders
)

LINK_TO_HOME=(
  zsh                    # config/zsh/.zshrc, .zprofile → ~/.zshrc, ~/.zprofile
  vim                    # config/vim/.vimrc            → ~/.vimrc
)

LINK_TO_SUBDIR=(
  "claude=.claude"       # config/claude/* → ~/.claude/* (Claude Code は ~/.config ではなく ~/.claude を読む)
)


# --- 配列ヘルパー (配列に要素が含まれるかを判定) ---------------------------
# Bash 3.x との互換性のため、配列の存在チェックには ${arr[@]+"${arr[@]}"} という
# 一見奇妙な記法を使う。これは「配列が未定義 or 空のとき何も展開しない」イディオム。
# set -u を有効にしているため、空配列をそのまま展開するとエラーになる。
contains() {
  local needle="$1"; shift
  local x
  for x in ${@+"$@"}; do
    [ "$x" = "$needle" ] && return 0
  done
  return 1
}


# --- フォルダ名 → バイナリ名の解決 -----------------------------------------
# 1. NO_BINARY に含まれていれば空文字を返す (検出スキップ = 常にリンク)
# 2. BINARY_AS に "フォルダ名=..." の形で書かれていればその値を返す
# 3. どちらでもなければフォルダ名そのものをバイナリ名として返す
binary_for() {
  local folder="$1" pair

  if contains "$folder" ${NO_BINARY[@]+"${NO_BINARY[@]}"}; then
    printf ''
    return
  fi

  for pair in ${BINARY_AS[@]+"${BINARY_AS[@]}"}; do
    case "$pair" in
      "$folder="*)
        # ${pair#*=} は文字列の先頭から "=" までを取り除いた残り (= バイナリ名)
        printf '%s' "${pair#*=}"
        return
        ;;
    esac
  done

  printf '%s' "$folder"
}


# --- フォルダ名 → ホーム配下のリンク先ディレクトリの解決 ---------------------
# LINK_TO_SUBDIR に "フォルダ名=ディレクトリ名" があればそのディレクトリ名を
# 標準出力に返す (終了コード 0)。無ければ何も出さず非ゼロを返す。
subdir_for() {
  local folder="$1" pair
  for pair in ${LINK_TO_SUBDIR[@]+"${LINK_TO_SUBDIR[@]}"}; do
    case "$pair" in
      "$folder="*)
        printf '%s' "${pair#*=}"
        return 0
        ;;
    esac
  done
  return 1
}


# --- ツールが導入済みか判定 -------------------------------------------------
# command -v は PATH から実行可能ファイルを探す。見つかれば終了コード 0。
# 出力は要らないので /dev/null に捨てる。
is_tool_installed() {
  local bin
  bin="$(binary_for "$1")"

  # 空文字なら検出不要 (= 常にインストール済み扱い)
  [ -z "$bin" ] && return 0

  command -v "$bin" >/dev/null 2>&1
}


# --- yes/no プロンプト ------------------------------------------------------
# 引数:
#   $1: ユーザーに表示する質問文
#   $2: デフォルトの選択 ("y" または "n"。省略時は "n")
#
# 戻り値:
#   0 = yes、1 = no
#
# 注意:
#   NON_INTERACTIVE モードでは何も聞かず、デフォルトに従って即座に返す。
prompt_yn() {
  local prompt="$1" default="${2:-n}" hint reply

  # デフォルトの選択を [Y/n] / [y/N] のように大文字で示す
  if [ "$default" = "y" ]; then hint="[Y/n]"; else hint="[y/N]"; fi

  # 対話モードでない (= -y 指定) ならデフォルトに従う
  if [ "$NON_INTERACTIVE" -eq 1 ]; then
    [ "$default" = "y" ]
    return
  fi

  # 入力が y/n のどちらかになるまで聞き直す
  # </dev/tty を付けることで、スクリプトがパイプ越しに呼ばれていてもキー入力を読める
  while :; do
    read -r -p "$prompt $hint " reply </dev/tty || reply=""
    reply="${reply:-$default}"      # 空入力ならデフォルト値を採用
    case "$reply" in
      y|Y|yes|YES) return 0 ;;
      n|N|no|NO)   return 1 ;;
    esac
  done
}


# ============================================================================
# 「実行計画 (plan)」の作成
# ============================================================================
# やりたいこと: どのファイルをどこに symlink するか、リストを作る。
#
# Bash 3.x には連想配列が使えないため、3 つの「並列配列」で表現する。
# 同じインデックス i の要素が組になっている:
#   PLAN_TARGET[i] = リンクの「作成先」(例: ~/.zshrc)
#   PLAN_SOURCE[i] = リンクの「実体」  (例: ~/dotfiles/zsh/.zshrc)
#   PLAN_TOOL[i]   = 関連するツール名  (例: zsh) — 検出に使う
# ============================================================================

PLAN_TARGET=()
PLAN_SOURCE=()
PLAN_TOOL=()

# 3 つの並列配列に 1 件追加する
add_plan() {
  PLAN_TARGET+=("$1")
  PLAN_SOURCE+=("$2")
  PLAN_TOOL+=("$3")
}


# --- config/<name>/ をスキャン --------------------------------------------
# 通常は ~/.config/<name> へディレクトリごとリンクする。
# ただし LINK_TO_HOME に含まれるフォルダは、中のファイルを個別に ~/<ファイル名> へリンクする。
if [ -d "$DOTFILES_DIR/config" ]; then
  for src in "$DOTFILES_DIR/config"/*; do
    [ -d "$src" ] || continue        # ディレクトリ以外はスキップ
    name="$(basename "$src")"

    if contains "$name" ${LINK_TO_HOME[@]+"${LINK_TO_HOME[@]}"}; then
      # ファイル単位でホーム直下にリンク
      for f in "$src"/*; do
        [ -e "$f" ] || continue
        [ -d "$f" ] && continue       # サブディレクトリは扱わない
        add_plan "$HOME/$(basename "$f")" "$f" "$name"
      done
    elif subdir="$(subdir_for "$name")"; then
      # ファイル単位で ~/<subdir>/ にリンク (例: claude → ~/.claude/)
      for f in "$src"/*; do
        [ -e "$f" ] || continue
        [ -d "$f" ] && continue       # サブディレクトリは扱わない
        add_plan "$HOME/$subdir/$(basename "$f")" "$f" "$name"
      done
    else
      # ディレクトリごと ~/.config/<name> にリンク
      add_plan "$HOME/.config/$name" "$src" "$name"
    fi
  done
fi


# --- 計画が空なら早期終了 ---------------------------------------------------
if [ "${#PLAN_TARGET[@]}" -eq 0 ]; then
  warn "Nothing to link. Is the repo layout correct?"
  exit 0
fi


# ============================================================================
# 計画の表示
# ============================================================================

# ヘッダー
info "${BOLD}Dotfiles setup${RESET}"
info "  repo: $DOTFILES_DIR"
info "  mode: $([ $DRY_RUN -eq 1 ] && echo 'dry-run' || echo 'apply')"
echo

# --- 検出セクション ---------------------------------------------------------
# 計画に出てきたツールの一覧 (重複なし) を作って、それぞれが導入済みかを表示。
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


# --- 計画セクション (表示を短くするためのヘルパー) -------------------------
# ${1/#$HOME/~} は「先頭の $HOME を ~ に置換」する Bash の機能。
# 例: /Users/katadai/.zshrc → ~/.zshrc
short_home()   { printf '%s' "${1/#$HOME/~}"; }
short_source() { printf '%s' "${1/#$DOTFILES_DIR/.}"; }

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


# --- dry-run なら計画を見せて終了 -------------------------------------------
if [ "$DRY_RUN" -eq 1 ]; then
  info "${DIM}--dry-run; no changes made.${RESET}"
  exit 0
fi


# --- 実行確認 ---------------------------------------------------------------
if ! prompt_yn "Proceed?" y; then
  info "Aborted."
  exit 0
fi
echo


# ============================================================================
# 実際にリンクを張る処理
# ============================================================================

# バックアップファイル名を生成 (例: ~/.zshrc.bak.20260531-164500)
backup_path() { printf '%s.bak.%s' "$1" "$TIMESTAMP"; }


# --- 1 件分のリンク作成処理 -------------------------------------------------
# 引数: $1=リンクの作成先  $2=実体のパス  $3=ツール名
#
# 動作の流れ:
#   1. ツール未導入なら、(--all 指定でない限り) スキップ
#   2. 既にリンクが正しく張られているならスキップ
#   3. 別の場所を指すリンクが既にある → 確認のうえ削除
#   4. 通常ファイル/ディレクトリが既にある → 確認のうえバックアップ
#   5. シンボリックリンクを作成
link_one() {
  local target="$1" source="$2" tool="$3"

  # 1. ツール未導入なら基本スキップ (--all 指定時は無視して進める)
  if [ "$LINK_ALL" -ne 1 ] && ! is_tool_installed "$tool"; then
    skip "$(short_home "$target") (skip: $tool not installed)"
    return
  fi

  # 2 & 3. 既に target が symlink の場合の処理
  if [ -L "$target" ]; then
    local current
    current="$(readlink "$target")"

    # 既に正しいリンク先になっていれば何もしない (冪等性)
    if [ "$current" = "$source" ]; then
      skip "$(short_home "$target") (already linked)"
      return
    fi

    # 別の場所を指している → 置き換えてよいか確認
    if [ "$FORCE" -eq 1 ] || prompt_yn "  $(short_home "$target") points to $current. Replace?" n; then
      rm "$target"
    else
      skip "$(short_home "$target") (kept existing symlink)"
      return
    fi

  # 4. 通常のファイルやディレクトリが存在する場合
  elif [ -e "$target" ]; then
    if [ "$FORCE" -eq 1 ]; then
      # --force ならバックアップを取らずに削除
      rm -rf "$target"
    else
      # バックアップを取って退かす
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

  # 5. リンク作成
  #    mkdir -p で親ディレクトリも作成しておく (~/.config が無い場合に備える)
  mkdir -p "$(dirname "$target")"
  ln -s "$source" "$target"
  ok "$(short_home "$target") → $(short_source "$source")"
}


# --- 全件を順番に処理 -------------------------------------------------------
errors=0
for i in "${!PLAN_TARGET[@]}"; do
  if ! link_one "${PLAN_TARGET[$i]}" "${PLAN_SOURCE[$i]}" "${PLAN_TOOL[$i]}"; then
    errors=$((errors + 1))
  fi
done


# --- Yazi プラグインの復元 --------------------------------------------------
# プラグイン本体は ~/.config/yazi/plugins/ に配置されるが gitignore 済みのため、
# package.toml をマニフェストとして `ya pkg install` で復元する。
if command -v ya >/dev/null 2>&1 && [ -f "$HOME/.config/yazi/package.toml" ]; then
  info "Restoring Yazi plugins (ya pkg install)..."
  ya pkg install || warn "ya pkg install failed."
fi


# --- 結果サマリ -------------------------------------------------------------
echo
if [ "$errors" -gt 0 ]; then
  warn "Done with $errors error(s)."
  exit 1
fi
info "${BOLD}Done.${RESET}"
