# dotfiles

個人用のdotfiles。すべての設定をリポジトリ内の `.config/` に集約し、`setup.sh`でsymlinkを張ります。

## ディレクトリ構成

```
.
├── .config/        # すべての設定をここに集約
│   ├── alacritty/  # → ~/.config/alacritty (ディレクトリごとリンク)
│   ├── nvim/       # → ~/.config/nvim
│   ├── starship/   # → ~/.config/starship
│   ├── zsh/        # → ~/.zshrc, ~/.zprofile (中のファイルをホーム直下にリンク)
│   ├── vim/        # → ~/.vimrc
│   └── ...
├── setup.sh        # symlinkセットアップスクリプト
└── .gitignore
```

**リンク規則:**

| リポジトリ内のパス               | リンク先                  | 備考                                |
| -------------------------------- | ------------------------- | ----------------------------------- |
| `dotfiles/.config/<name>/`       | `~/.config/<name>`        | デフォルト (ディレクトリごとリンク) |
| `dotfiles/.config/<name>/<file>` | `~/<file>`                | `LINK_TO_HOME` に指定したフォルダ   |

## セットアップ

新しいマシンで使うとき:

```sh
git clone git@github.com:OverfittingDitto/dotfiles.git ~/dotfiles
cd ~/dotfiles
./setup.sh
```

`setup.sh` は対話モードで動作し、各ツールが導入済みかを `command -v` で確認したうえで、symlinkを作成します。既存ファイルがあれば確認のうえバックアップ (`<file>.bak.<timestamp>`) してから置き換えます。

### オプション

| フラグ         | 動作                                                         |
| -------------- | ------------------------------------------------------------ |
| `-n, --dry-run`| 実行内容を表示するだけで変更しない                           |
| `-y, --yes`    | 対話なし。既存ファイルは自動でバックアップして置き換え       |
| `-f, --force`  | 既存ファイルをバックアップせず上書き                         |
| `-a, --all`    | バイナリ未導入のツールも含めてすべてsymlinkを張る            |
| `-h, --help`   | ヘルプを表示                                                 |

### vimだけクイックインストール (持ち運び用)

SSH先など git やシェル環境構築が難しいマシンで、`.vimrc` だけ持ち込みたい場合:

```sh
# 最小: vimrc のみ (colorscheme は desert にフォールバック)
curl -sL https://raw.githubusercontent.com/OverfittingDitto/dotfiles/main/.config/vim/.vimrc -o ~/.vimrc

# フル: catppuccin_frappe も入れる
mkdir -p ~/.vim/colors
curl -sL https://raw.githubusercontent.com/OverfittingDitto/dotfiles/main/.config/vim/colors/catppuccin_frappe.vim -o ~/.vim/colors/catppuccin_frappe.vim
```

vimrc は完全に外部依存なし (vim 9.0+ 推奨、古いvimでも自動で機能を縮退)。

## dotfileの追加

### `~/.config/<tool>` を追加する (大多数のケース)

1. `~/.config/<tool>` を `~/dotfiles/.config/<tool>` に移動
2. `ln -s ~/dotfiles/.config/<tool> ~/.config/<tool>` でsymlinkを張る
3. `git add .config/<tool> && git commit`

`setup.sh` はリポジトリ内のディレクトリを自動でスキャンするので、スクリプト本体の編集は不要です。

### ホーム直下のdotfileを追加する

例: `~/.tmux.conf` をリポジトリで管理したい場合 (本来は `~/.config/tmux/tmux.conf` 等で済むなら不要)。

1. `dotfiles/.config/<group>/` を作成し、ファイルを置く: `mv ~/.tmux.conf ~/dotfiles/.config/tmux-home/.tmux.conf`
2. `setup.sh` の `LINK_TO_HOME` 配列にフォルダ名を追加: `tmux-home`
3. `ln -s ~/dotfiles/.config/tmux-home/.tmux.conf ~/.tmux.conf`
4. コミット

### 検出/リンクルールのカスタマイズ

`setup.sh` 冒頭の設定テーブルを編集します。

```sh
# バイナリ検出をスキップ (アーカイブ等)
NO_BINARY=(
  configarchive
)

# フォルダ名とバイナリ名が違う
BINARY_AS=(
  vscode=code-insiders
)

# .config/<name>/ の中身を ~/ 直下にリンク
LINK_TO_HOME=(
  zsh
  vim
)
```

## 関連ツール

このdotfilesで設定を管理しているツール、またはシェル設定から参照されているツールの一覧。括弧内はリポジトリ内のconfig所在 (無いものは外部依存のみ)。

### ターミナル
- **Ghostty** (`.config/ghostty/`) — macOSメインターミナル。Catppuccin Frappe + HackGen35
- **Alacritty** (`.config/alacritty/`) — クロスプラットフォーム代替。Linux/WSL用候補として残置
- **tmux** (`.config/tmux/`) — マルチプレクサ。プレフィックス `C-a`、`prefix g` で lazygit ポップアップ

### シェル / プロンプト
- **zsh** (`.config/zsh/`) — 標準シェル。`.zshrc`, `.zprofile`
- **sheldon** (`.config/sheldon/`) — zshプラグインマネージャ
- **starship** (`.config/starship/`) — クロスシェルプロンプト
- sheldon経由のzshプラグイン: `zsh-defer`, `zsh-completions`, `zsh-autosuggestions`, `fast-syntax-highlighting`, `zsh-history-substring-search`

### エディタ
- **Neovim** (`.config/nvim/`) — メインエディタ。`vim.pack` でプラグイン管理、blink.cmp + LSP
- **Vim** (`.config/vim/`) — 持ち運び用シンプル設定
- **Zed** (`.config/zed/`) — GUIエディタ

### パッケージ / バージョン管理
- **Homebrew** — macOS / Linuxbrew パッケージマネージャ。`.zprofile` で自動 activate
- **mise** (`.config/mise/`) — Go / Node / Python / Rust / pnpm / uv のランタイム管理

### ファイル操作 (zshエイリアス)
- **eza** — `ls` の代替。アイコンと Git ステータス表示
- **dust** — `du` の代替。直感的な使用量表示
- **trash** — `rm` の代替。macOSゴミ箱に移動 (`brew install trash`)
- **zoxide** — `cd` の代替。アクセス頻度ベースで賢く移動
- **bottom (btm)** — `top` の代替。リッチなシステムモニタ
- **htop** (`.config/htop/`) — 従来のプロセスビューア
- **oil.nvim** — Neovim組み込みファイラー

### 検索
- **fzf** (`.config/fzf/`) — ファジーファインダー。`Ctrl-T` / `Ctrl-R` / `Alt-C` 等
- **ripgrep (rg)** — 高速 grep。`rf` 関数で fzf と組み合わせ対話検索
- **fd** — 高速 find。fzf関数の内部で使用
- **ghq** — git リポジトリ管理。`Ctrl-G` で fzf 検索 → cd
- **bat** — `cat` の代替。シンタックスハイライト、fzf preview にも使用

### Git
- **git** — VCS本体
- **lazygit** — git TUI。tmux内 `prefix g` でポップアップ
- **gh** — GitHub CLI。リポジトリ作成、PR操作等
- **delta** — diff/`git log` ビューア

### 開発環境補助
- **OrbStack** — macOS用 Docker 代替 + Linux VM。`.zprofile` でシェル統合
- **Obsidian** — Markdownノート (CLI起動用に PATH 追加)

## 管理しないもの

セキュリティや実用上の理由から、以下はリポジトリ管理外にしています:

- `~/.ssh/` — SSH秘密鍵
- `~/.claude.json`, `~/.claude/` — Claude設定 (セッション情報を含む)
- `~/.config/gh/` — GitHub CLI (OAuthトークンを含む)
- `~/.config/raycast/` — マシン固有の拡張データ (約7MB)
- 履歴/キャッシュ系: `~/.zsh_history`, `~/.viminfo`, `~/.cache/`, など

## メモ

- Starshipは `~/.config/starship.toml` の直置きを避けるため、`STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"` を `.zshrc` で指定してサブディレクトリ管理にしています。
- miseは作業ディレクトリから `.config/mise/config.toml` をproject-level configとして検出するため、`~/dotfiles/` で作業すると未信頼エラーが出ます。初回セットアップ後に以下を実行してください:
  ```sh
  mise trust ~/dotfiles/.config/mise/config.toml
  ```
