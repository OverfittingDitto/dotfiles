# Setup fzf
# ~/.config/fzf/fzf.zsh
# ---------
# macOS Homebrew でインストールされた場合に限り PATH に追加 (Linux/WSL では不要)
if [ -d /opt/homebrew/opt/fzf/bin ] && [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
fi

# export FZF_TMUX=1
# export FZF_TMUX_OPTS="-p 80%"

# export FZF_DEFAULT_COMMAND='fd --type f --strip-cwd-prefix --hidden --follow --exclude .git'
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow'
export FZF_DEFAULT_OPTS="
--multi --border=rounded --height 85% --layout=reverse
--tmux 80%
"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=numbers {}' --preview-window 'down,60%'"
export FZF_ALT_C_COMMAND='fd --type d --hidden'
export FZF_ALT_C_OPTS="--preview 'eza --icons --tree --color=always {}'"
# export FZF_CTRL_R_OPTS=''
export FZF_CTRL_R_OPTS="--preview 'echo {}' --preview-window=up,3,wrap"

source <(fzf --zsh)


# fzfでファイルをプレビュー付きで検索する専用の関数
ff() {
  fzf --preview 'bat --color=always --style=numbers {}'
}

# rg と fzf を組み合わせた対話的検索関数
rf() {
  # 依存コマンドの存在チェック
  if ! command -v rg &> /dev/null || ! command -v fzf &> /dev/null || ! command -v bat &> /dev/null; then
    echo "Error: 'rg', 'fzf', 'bat' are required for this function." >&2
    return 1
  fi

  local RG_PREFIX="rg --column --line-number --no-heading --color=always --smart-case "
  local INITIAL_QUERY="${*:-}"

  # EDITOR変数が設定されていなければvimを、されていればそのエディタを使う
  local EDITOR=${EDITOR:-vim}

  fzf --ansi --disabled --query "$INITIAL_QUERY" \
    --bind "start:reload:$RG_PREFIX {q}" \
    --bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
    --bind "alt-enter:unbind(change,alt-enter)+change-prompt(2. fzf> )+enable-search+clear-query" \
    --color "hl:-1:underline,hl+:-1:underline:reverse" \
    --prompt '1. ripgrep> ' \
    --delimiter : \
    --preview 'bat --color=always {1} --highlight-line {2}' \
    --preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
    --bind "enter:become($EDITOR {1} +{2})"
}

# ghq
ghq-fzf() {
  local src=$(ghq list | fzf --preview "bat --color=always --style=header,grid --line-range :80 $(ghq root)/{}/README.*")
  if [ -n "$src" ]; then
    BUFFER="cd $(ghq root)/$src"
    zle accept-line
  fi
  zle -R -c
}

zle -N ghq-fzf
bindkey '^g' ghq-fzf
# --- キーバインドの設定 ---
# Ctrl+F で上記の関数を呼び出すZleウィジェットを作成
zle -N rf_widget
rf_widget() {
  # 現在のコマンドラインの内容を初期クエリとして関数に渡す
  rf "$(zle -c)"
  # プロンプトを再描画
  zle reset-prompt
}
# Ctrl+Fにウィジェットを割り当て
bindkey '^f' rf_widget
