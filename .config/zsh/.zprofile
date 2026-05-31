# Homebrew の PATH 等を設定する。インストール先は OS / アーキテクチャで異なる:
#   macOS (Apple Silicon)  : /opt/homebrew/bin/brew
#   macOS (Intel)          : /usr/local/bin/brew
#   Linux                  : /home/linuxbrew/.linuxbrew/bin/brew
# 見つかったものだけを実行する。
for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew /home/linuxbrew/.linuxbrew/bin/brew; do
    [ -x "$brew_bin" ] && eval "$("$brew_bin" shellenv)" && break
done

# mise が入っていれば activate
command -v mise &>/dev/null && eval "$(mise activate zsh)"

# Obsidian (macOS の .app 内バイナリ) を PATH に追加
if [ -d "/Applications/Obsidian.app/Contents/MacOS" ]; then
    export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
fi

# OrbStack のシェル統合 (存在しなければ無視)
[ -f "$HOME/.orbstack/shell/init.zsh" ] && source "$HOME/.orbstack/shell/init.zsh"
