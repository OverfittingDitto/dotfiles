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
