# dotfiles

個人用のdotfiles。`~/.config`配下と一部のホーム直下のdotfileを管理し、`setup.sh`でsymlinkを張ります。

## ディレクトリ構成

```
.
├── .config/        # ~/.config 配下の設定 (各サブディレクトリごとにsymlink)
│   ├── alacritty/
│   ├── nvim/
│   ├── starship/
│   └── ...
├── zsh/            # ~/.zshrc, ~/.zprofile
├── vim/            # ~/.vimrc
├── setup.sh        # symlinkセットアップスクリプト
└── .gitignore
```

**リンク規則:**

| リポジトリ内のパス               | リンク先                  |
| -------------------------------- | ------------------------- |
| `dotfiles/.config/<name>/`       | `~/.config/<name>`        |
| `dotfiles/<group>/<file>`        | `~/<file>`                |

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

### `~/.config/<tool>` を追加する

1. `~/.config/<tool>` を `~/dotfiles/.config/<tool>` に移動
2. `ln -s ~/dotfiles/.config/<tool> ~/.config/<tool>` でsymlinkを張る
3. `git add .config/<tool> && git commit`

次回以降は他マシンで `./setup.sh` を実行すれば反映されます。

### ホーム直下のdotfileを追加する

例: `~/.tmux.conf` をリポジトリで管理したい場合。

1. `~/dotfiles/<group>/` ディレクトリを作成 (例: `mkdir tmux`)
2. ファイルを移動: `mv ~/.tmux.conf ~/dotfiles/tmux/.tmux.conf`
3. symlink: `ln -s ~/dotfiles/tmux/.tmux.conf ~/.tmux.conf`
4. コミット

`setup.sh` はリポジトリ内のディレクトリを自動でスキャンするので、スクリプト本体の編集は不要です。

### 検出ルールのカスタマイズ

`setup.sh` 内の `NO_BINARY` / `BINARY_AS` セクションを編集します。

```sh
# 例: アーカイブのため検出スキップ
NO_BINARY=(
  configarchive
)

# 例: フォルダ名とバイナリ名が異なるとき
BINARY_AS=(
  code=code-insiders
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
