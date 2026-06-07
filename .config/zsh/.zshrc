# ======================================================================
# XDG Base Directory Specification への準拠
# ======================================================================
# システムがコマンドを探すパスに${HOME}/.local/binを追加
export PATH=${HOME}/.local/bin:$PATH

# 各種設定ファイルの場所を定義
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_STATE_HOME="$HOME/.local/state"

# Zshが使用するディレクトリがなければ作成する
mkdir -p "$XDG_CACHE_HOME/zsh"
mkdir -p "$XDG_STATE_HOME/zsh"

# ======================================================================
# エイリアス (基本コマンド)
# ======================================================================
alias c='clear'

# trash を PATH に追加 (rm の置換先。エイリアス自体は下のガード内で張る)
if [ -d /opt/homebrew/opt/trash/bin ]; then
    export PATH="/opt/homebrew/opt/trash/bin:$PATH"
fi

# ======================================================================
# エイリアス (標準コマンドの置換) — AI エージェント実行時は無効化
# ======================================================================
# 以下は標準コマンドを別ツールに差し替える / 挙動を変えるエイリアス。代替ツール
# はオプションや出力が GNU/coreutils と非互換なものがあり (例: du→dust は
# `du -sh` が壊れる、cp -i は非対話で確認待ちになる、rm→trash は -rf 非互換、
# grep/find/ps→rg/fd/procs はフラグが別物)、AI エージェントが標準コマンドの
# つもりで実行すると壊れる。
#
# 多くの CLI AI は非対話シェルでコマンドを実行し .zshrc を読まないため元々対象外。
# Claude Code のように対話シェル環境をスナップショットして使うものだけが影響を
# 受けるので、それらは env 変数で判定してエイリアスを定義しない (= 素のコマンドを
# 使う)。代替ツールの色 / アイコン / ページャは非TTYで自動無効化されるため、AI が
# それらを使って得する装飾は元々無い。人間の対話端末では従来どおり全て有効。
#
# 新しいエージェントは _is_ai_agent に1行足すだけでよい。
#
# 注意: ps を procs に差し替えるため、内部で `ps -o ...` を使う関数
# (nossh / _sync_ssh_env) は `command ps` を使い、このエイリアスを迂回している。
_is_ai_agent() {
    [[ -n "$CLAUDECODE"    ]] && return 0  # Claude Code
    [[ -n "$AI_AGENT"      ]] && return 0  # 汎用 (Claude Code も設定。将来の規約用)
    [[ -n "$CODEX_SANDBOX" ]] && return 0  # OpenAI Codex CLI (seatbelt 等)
    return 1
}
if ! _is_ai_agent; then
    # rm はゴミ箱へ
    if command -v trash &>/dev/null; then
        alias rm='trash'
    fi
    # cp / mv は上書き前に確認
    alias cp='cp -i'
    alias mv='mv -i'

    # cd -> zoxide
    if command -v zoxide &>/dev/null; then
        alias cd='z'
        alias cdi='zi'
    fi
    # ls -> eza
    if command -v eza &>/dev/null; then
        alias ls='eza --icons'
        alias ll='eza --icons -l -g --git'  # 詳細表示 + Gitステータス
        alias lt='eza --icons -T'           # ツリー表示
    fi
    # cat -> bat (シンタックスハイライト)
    if command -v bat &>/dev/null; then
        alias cat='bat'
    fi
    # grep -> ripgrep (高速 grep)
    if command -v rg &>/dev/null; then
        alias grep='rg'
    fi
    # find -> fd (直感的な find)
    if command -v fd &>/dev/null; then
        alias find='fd'
    fi
    # du -> dust (分かりやすい du)
    if command -v dust &>/dev/null; then
        alias du='dust'
    fi
    # ps -> procs (モダンな ps)
    if command -v procs &>/dev/null; then
        alias ps='procs'
    fi
    # top -> btm (リッチな top)
    if command -v btm &>/dev/null; then
        alias top='btm'
    fi
    # diff -> delta (見やすい diff)
    if command -v delta &>/dev/null; then
        alias diff='delta'
    fi
fi
unset -f _is_ai_agent

# ======================================================================
# エイリアス (Git)
# ======================================================================
alias gs='git status'
alias gp='git pull'
alias gc='git commit -m'
alias gco='git checkout'
alias gl='git log --graph --oneline'

# ======================================================================
# Nix / home-manager
# ======================================================================
# `nh home switch` を打つと自動で -c default --impure を付けるラッパ関数。
# flake 出力名が default、かつ impure flake のため両オプションは常に固定。
# search / clean など他の nh サブコマンドはそのまま素通しする。
# Nix の無い環境 (nh 未導入) では下の関数ブロックをコメントアウトして無効化する。
nh() {
  if [[ "$1" == "home" && "$2" == "switch" ]]; then
    command nh home switch -c default --impure "${@:3}"
  else
    command nh "$@"
  fi
}

# ======================================================================
# エイリアス (ナビゲーション)
# ======================================================================
alias ..='cd .. && pwd'
alias ...='cd ../.. && pwd'
alias ....='cd ../../.. && pwd'

# ディレクトリスタック (dで一覧表示, 数字でジャンプ)
# alias d='dirs -v'
# alias 1='cd -1'
# alias 2='cd -2'
# alias 3='cd -3'

# Yazi: ファイラーを抜けたとき最後にいたディレクトリへシェルも移動する。
# 子プロセス(yazi)は親シェルのcwdを変えられないため、--cwd-file に終了時の
# パスを書き出させ、親シェルがそれを読んで cd する (Yazi公式推奨の統合方法)。
# cd は zoxide で z に差し替えられているので builtin cd で素のcdを呼ぶ。
if command -v yazi &>/dev/null; then
    y() {
        local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
        command yazi "$@" --cwd-file="$tmp"
        IFS= read -r -d '' cwd < "$tmp"
        [ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
        command rm -f -- "$tmp"
    }
fi

# ======================================================================
# Zsh 補完機能 (Completion)
# ======================================================================
# 補完リストの色を設定 (fzf-tabでも使われる)
zstyle ':completion:*' list-colors "${LS_COLORS}"
# `red`, `green`などの色変数を使えるようにする
autoload -Uz colors && colors

# autoload -Uz compinit &&compinit

# 補完候補で、大文字・小文字を区別しない（大文字を入力した場合は区別する）
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
# 補完候補から親ディレクトリ(..)とカレントディレクトリ(.)を除外
zstyle ':completion:*' ignore-parents parent pwd ..
zstyle ':completion:*:default' menu select=1

# ======================================================================
# Zsh 履歴 (History)
# ======================================================================
# 履歴ファイルの場所をXDG規約に従って設定
HISTFILE="$XDG_STATE_HOME/zsh/history"

# メモリ上とファイルに保存する履歴の件数
HISTSIZE=10000
SAVEHIST=10000

# rootユーザーの履歴は残さない
if [ $UID = 0 ]; then
    unset HISTFILE
    SAVEHIST=0
fi

# 履歴に関する便利なオプション設定
setopt append_history         # 履歴ファイルに追記する
setopt share_history          # 複数ターミナルで履歴を共有する
setopt hist_ignore_all_dups   # 重複するコマンドは古い方を削除
setopt hist_ignore_space      # スペースで始まるコマンドを履歴に残さない
setopt hist_save_no_dups      # 履歴保存時に重複を削除
setopt hist_expire_dups_first # 履歴削除時に重複から削除
setopt extended_history       # 履歴にタイムスタンプを記録
setopt inc_append_history     # コマンド実行後すぐに履歴ファイルに追記

# ======================================================================
# Zsh オプション (setopt)
# ======================================================================
setopt auto_cd              # ディレクトリ名だけでcdする
setopt auto_pushd           # cdしたディレクトリをスタックに自動で追加
setopt pushd_ignore_dups    # ディレクトリスタックの重複を無視
setopt correct              # 簡単なコマンドのタイプミスを修正
setopt print_eight_bit      # 日本語ファイル名などを正しく表示

# ======================================================================
# SSH 環境変数の制御
# ======================================================================
# プロセスツリーを祖先方向にたどり、sshd が見つかれば成功(0)を返す共通ヘルパー。
# nossh と _sync_ssh_env の両方から使う。
# 注意1: local をループ内で再宣言すると zsh の typeset の挙動で 2 周目以降に
#        既存値が標準出力へ漏れるため、local はループの外で一度だけ宣言する。
# 注意2: ps は procs に差し替えられている場合があるため command ps で素の ps を呼ぶ。
_has_sshd_ancestor() {
    local pid=$$ ppid comm
    while [[ $pid -gt 1 ]]; do
        ppid=$(command ps -o ppid= -p "$pid" 2>/dev/null | tr -d ' ')
        comm=$(command ps -o comm= -p "$pid" 2>/dev/null)
        [[ "$comm" == *sshd* ]] && return 0
        [[ -z "$ppid" || "$ppid" == "$pid" ]] && break
        pid=$ppid
    done
    return 1
}

# 残存した SSH 環境変数を手動でクリアする。ただし実際に SSH 接続中なら何もしない。
# (例: tmux 経由で SSH_* が引き継がれ、ローカルなのに SSH 扱いになった時のリセット)
nossh() {
    if _has_sshd_ancestor; then
        echo "実際にSSH接続中のため unset しません"
        return 1
    fi
    unset SSH_CONNECTION SSH_CLIENT SSH_TTY
}

# 起動時に SSH 状態をプロセスツリーで判定し、環境変数の欠落・引き継ぎを補正する。
# starship が ssh_only=true でホスト名表示に使うため、プロンプト描画前に確定させる。
_sync_ssh_env() {
    # sshd がプロセスツリーを経由せず ProxyCommand で接続する場合 (OrbStack,
    # VSCode Remote SSH 等) は SSH_CONNECTION が sshd 側でセットされた状態で
    # 渡ってくるので、既にセットされていればそのまま信頼する。
    if [[ -n "$SSH_CONNECTION" || -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then
        return
    fi
    # Tmux内: 新規WindowはTmuxサーバーの子プロセスなのでsshd検出不可。
    # tmuxのupdate-environmentがattach時にSSH_CONNECTIONを伝播するため信頼する。
    if [[ -n "$TMUX" ]]; then
        return
    fi
    if _has_sshd_ancestor; then
        export SSH_CONNECTION="${SSH_CONNECTION:-detected}"
    else
        unset SSH_CONNECTION SSH_CLIENT SSH_TTY
    fi
}
_sync_ssh_env
unset -f _sync_ssh_env   # 起動時のみ使用。_has_sshd_ancestor は nossh が使うため残す

# ======================================================================
# 各種ツールの初期化
# ======================================================================

# プラグインマネージャー (sheldon)
# 使用プラグイン例: zsh-defer,zsh-completion,zsh-autosuggestion,zsh-syntax-highlighting
if command -v sheldon &>/dev/null; then
    eval "$(sheldon source)"
fi

# プロンプト (starship)
# ~/.config直下にtomlを置かれるのを避けてサブディレクトリに格納
export STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"
if command -v starship &>/dev/null; then
    eval "$(starship init zsh)"
fi

# バージョン管理 (mise)
# .zshrcでは軽量なhook-envを使い、シェルの起動を高速化
# PATH設定などを行う `eval "$(mise activate zsh)"` は .zprofile に書くのが望ましい
if command -v mise &>/dev/null; then
    eval "$(mise hook-env --shell zsh)"
fi

# fzf (キーバインドと補完)
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh ] && source "${XDG_CONFIG_HOME:-$HOME/.config}"/fzf/fzf.zsh

# 高速なディレクトリ移動 (zoxide)
# zoxide は chpwd/precmd フックを使うため、他ツール (fzf 等) の初期化より後、
# シェル設定の最後で初期化する (zoxide doctor の推奨。これより後にフックを
# 足す初期化を置かないこと。順序が崩れると起動時に警告が出る)。
if command -v zoxide &>/dev/null; then
    eval "$(zoxide init zsh)"
fi
