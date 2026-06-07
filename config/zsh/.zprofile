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

# home-manager のセッション変数 (NH_FLAKE / LOCALE_ARCHIVE 等) を読み込む。
# このリポジトリは .zshrc を自前管理し programs.zsh を使わないため、home-manager
# が用意する hm-session-vars.sh は自動 source されない。明示的に読み込むことで
# `nh home switch ...` で NH_FLAKE が効く。Nix の無い環境では存在しないので無視。
[ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ] && \
    source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
