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
│   ├── git/        # → ~/.config/git/config (XDG)
│   └── ...
├── setup.sh        # symlinkセットアップスクリプト (Nixなし環境用)
├── flake.nix       # home-manager の入口。user/arch/home は実行時(--impure)に読む
├── flake.lock      # nixpkgs / home-manager のバージョン固定
├── nix/
│   └── common.nix  # Nixで入れるパッケージ + symlink定義 (マシン非依存)
└── .gitignore
```

**ツール導入と設定リンクは2層に分かれています:**

| | パッケージ導入 | 設定ファイルの symlink |
| ---- | ---- | ---- |
| **Nixあり** (Mac / SSH / WSL) | `nh home switch` | home-manager (`nix/common.nix`) |
| **Nixなし** | distro / brew 等で手動 | `./setup.sh` |

どちらの経路でも symlink は最終的に**リポジトリの実ファイル**を指すので、設定の編集は再ビルドなしで即反映されます。

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

## Nix (home-manager) でパッケージを管理する

CLIツールを Homebrew ではなく Nix で管理したい場合の手順。**Mac / SSH先 / WSL いずれでも同じ `nix/common.nix` でツールが揃います。** GUIアプリ (Ghostty, OrbStack, Zed 等) と `trash` は引き続き Homebrew に残します。

### 仕組み

リポジトリには `flake.nix` + `nix/common.nix` (パッケージ一覧 + symlink定義) を置きます。**ユーザー名・アーキテクチャ等のマシン固有値はリポジトリに一切書きません。** `flake.nix` が `switch` 実行時に環境から読みます:

| 値 | 読み方 (実行時) |
| ---- | ---- |
| アーキテクチャ | `builtins.currentSystem` |
| ユーザー名 | `$USER` |
| ホームディレクトリ | `$HOME` |

これらは環境を読むため `--impure` フラグが必要です (毎回付ける。エイリアスで隠せる)。`home-manager init` や、生成ファイルの手書き編集は不要です。

> 日常運用は素の `home-manager switch` ではなく `nh` (Nix操作のラッパCLI) を使います。switch 時にビルド過程をツリー表示し、前世代との「追加/削除/バージョン変更/closureサイズ増減」を色付き差分で見せてくれます。nh は `nix/common.nix` で導入され、初回 switch 後に PATH に入ります。flake 出力名が `default` なので `-c default`、impure flake なので `--impure` を付けます (= `nh home switch -c default --impure`)。

### 新しいマシンでのセットアップ

```sh
# 1. dotfiles を clone (symlink先になるのでこのパスは維持する)
git clone git@github.com:OverfittingDitto/dotfiles.git ~/dotfiles

# 2. Nix をインストール (Determinate Systems インストーラー。WSL2 もサポート)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
. /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh   # 現在のシェルで有効化

# 3. 適用 (ツール導入 + symlink作成がまとめて走る)
#    初回は home-manager も nh もまだ無いので nix run 経由で起動する。
#    この初回 switch が home-manager 自身と nh も入れるので、2回目以降は
#    `nh home switch ...` が直接使えるようになる。
nix run github:nix-community/home-manager -- switch --flake ~/dotfiles#default --impure

# 4. Yazi プラグインを復元 (Nix経由では setup.sh を通らないため手動。package.toml 基準)
ya pkg install
```

`-c default --impure` を毎回打つのが面倒なので、`.zshrc` に `nh` のラッパ関数を登録済み。`nh home switch` と打つだけで自動で `-c default --impure` が付く (`search` / `clean` 等の他サブコマンドはそのまま素通し):

```sh
nh() {
  if [[ "$1" == "home" && "$2" == "switch" ]]; then
    command nh home switch -c default --impure "${@:3}"
  else
    command nh "$@"
  fi
}
```

Nix の無い環境では `.zshrc` 内のこの関数ブロックをコメントアウトして無効化します。

以降の更新・ロールバックは (初回 switch で nh が PATH に入った後):

```sh
nh home switch           # ラッパが -c default --impure を補う。設定変更を適用
home-manager generations # 過去の世代一覧
home-manager rollback    # 1つ前に戻す
nix-tree                 # 依存関係ツリーを可視化 (TUI)
```

### nh の基本コマンド

日常で使う nh のコマンドはこれだけ覚えれば足りる。`nh home switch` はラッパ関数が `-c default --impure` を自動で補う。

| コマンド | 用途 |
| ---- | ---- |
| `nh home switch` | 設定を適用。ビルド過程をツリー表示し、前世代との差分 (追加/削除/バージョン/サイズ) を出す |
| `nh home switch --dry` | 適用せず差分だけ確認 (`common.nix` を編集した後の事前チェック) |
| `nh home switch --ask` | 差分を表示し、y/n の確認を挟んでから適用 |
| `nh search <名前>` | `search.nixos.org` を CLI で検索。コマンド名とパッケージ名が違うとき便利 |
| `nh clean user --keep 5` | 自分の古い世代を間引く (最低5世代は残す)。`--dry` で対象だけ確認 |

```sh
nh search ripgrep            # パッケージを探す
nh home switch --dry         # 変更を当てる前に差分を確認
nh home switch               # 適用
nh clean user --keep 5 --dry # GC対象を確認 (--dry を外すと実行)
```

> `nh clean` は後述の[容量管理](#容量管理)の `nix-collect-garbage -d` を nh 流に置き換えるもの。どちらも世代を消す操作なので任意のタイミングで。

### ログインシェルを zsh にする (Linux/WSL のみ)

Nixで入れた zsh は `~/.nix-profile/bin/zsh` に入りますが、ログインシェルの変更は home-manager の管轄外 (root が要る) です。**macOS はシステム zsh が既にログインシェルなので不要**。Linux/WSL で zsh をログインシェルにしたい場合のみ、root 権限のあるマシンで1回だけ実行します:

```sh
# Nix の zsh を有効なログインシェルとして登録 → 切り替え
grep -qxF "$HOME/.nix-profile/bin/zsh" /etc/shells || echo "$HOME/.nix-profile/bin/zsh" | sudo tee -a /etc/shells
chsh -s "$HOME/.nix-profile/bin/zsh"
```

次回ログインから zsh になります (現在のシェルですぐ試すなら `exec zsh -l`)。`~/.nix-profile/bin/zsh` は profile シンボリックリンクなので、home-manager を更新してもログインシェルのパスは変わりません。

> root の無い SSH 先ではこの方法は使えません。その場合は `~/.bashrc` にガード付きで `[ -x "$HOME/.nix-profile/bin/zsh" ] && exec "$HOME/.nix-profile/bin/zsh" -l` を足す等で代替します。

### 容量管理

Nix の store はパッケージの全依存を保持するため Homebrew より大きくなる (CLIツール一式で実測 約1.2〜2.4GB)。以下で抑える。これらは**daemon/マシン単位の設定**なのでリポジトリには含めず、各マシンで一度だけ行う (要 root)。

**自動で重複削除 (`auto-optimise-store`)** — 内容が同一のファイルをハードリンクで共有する。ロスレスで、世代やロールバックには一切影響しない。Determinate Nix ではユーザー設定用の `nix.custom.conf` に追記する:

```sh
echo "auto-optimise-store = true" | sudo tee -a /etc/nix/nix.custom.conf
sudo systemctl restart nix-daemon.service   # daemon に再読込させる
nix config show auto-optimise-store          # → true なら有効
```

**古い世代の掃除 (GC)** — switch を繰り返すと過去世代が積もる。不要になったら間引く (これは世代=ロールバック先を消す操作なので自動化はしない):

```sh
nix-collect-garbage -d     # 古い世代を削除し、未参照パスを回収
nix store optimise         # 既存分を手動で重複削除 (auto-optimise 前の分にも効く)
```

> `auto-optimise-store`（ファイル共有・ロスレス）と `nix-collect-garbage -d`（世代削除）は別物。前者は常時ONで無害、後者は履歴を捨てるので任意のタイミングで。

### ツール / リンク対象の追加

#### CLIツールを足す (基本フロー)

1. **パッケージ名を探す** — [search.nixos.org/packages](https://search.nixos.org/packages)。コマンド名とパッケージ名が違うことがある (例: `dust` / `delta` / `btm`→`bottom`)。
2. **`nix/common.nix` の `home.packages` に1行足す**:
   ```nix
   home.packages = with pkgs; [
     ...
     新しいツール名   # ← 追記
   ]
   ```
3. **適用**: `nh home switch -c default --impure` (追加されたパッケージが差分に出る)
4. **コミット** (main ではなくブランチで)

#### OS 限定で入れたいとき

`common.nix` の分岐ブロックに書く:
```nix
  ++ lib.optionals stdenv.isDarwin [ macだけのツール ]
  ++ lib.optionals stdenv.isLinux  [ linux/wsl だけのツール ];
```

#### まず試したいだけ (インストールせず一時的に)

```sh
nix shell nixpkgs#ツール名      # そのシェルの間だけ使える (終了で消える)
nix run   nixpkgs#ツール名 -- … # 1回だけ実行
```
気に入ったら `common.nix` に追記する、という流れが楽。

#### 設定ファイルも伴うツール

`xdg.configFile` (→ `~/.config/<name>`) か `home.file` (→ ホーム直下) にリンクを1行足す。

> **補足**: symlink 定義は `setup.sh` のリンク対象と別管理。新しい設定を足すときは両方を意識する (Nix側は `common.nix`、Nixなし側は `setup.sh` が自動スキャン)。

#### バージョンを上げる (既存ツール全体の更新)

```sh
nix flake update      # ~/dotfiles で実行 → flake.lock を最新 nixpkgs に更新
nh home switch -c default --impure   # 差分でどのツールが上がったか一目で分かる
```

#### 重い依存を引くツールだった場合

`override` で不要機能を切る (例は `fastfetch`)。太い依存は `nix path-info -rsh ~/.nix-profile | sort` や `nix-tree` で特定できる:
```nix
(ツール名.override { 何々Support = false; })
```

> Nix が無いマシンでは上記は効きません。従来どおり Homebrew / distro のパッケージマネージャで手動導入し、symlink は `setup.sh` を使ってください。

## vimだけクイックインストール (持ち運び用)

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
- **Nix / home-manager** (`flake.nix`, `nix/common.nix`) — CLIツールのクロスプラットフォーム管理。Mac/SSH/WSL 共通。詳細は[Nixセクション](#nix-home-manager-でパッケージを管理する)
- **nh** — Nix操作のラッパCLI (`programs.nh` で導入)。`nh home switch -c default --impure` で適用すると、ビルド過程のツリー表示と前世代との色付き差分が出る。`nh search` でパッケージ検索、`nh clean` でGCも
- **Homebrew** — macOS / Linuxbrew パッケージマネージャ。GUIアプリ (Cask) と `trash` 用に併用。`.zprofile` で自動 activate
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
- **git** (`.config/git/`) — VCS本体。設定は XDG (`~/.config/git/config`) で管理。メールは GitHub の noreply (公開前提)、`ghq.root` は `~/src` (ghq が `~` を展開) なので**マシン固有値ゼロ＝全部追跡**。`~/.gitconfig` は XDG より優先されるため、既存マシンでは一度だけ `mv ~/.gitconfig ~/.gitconfig.bak` で退避してから switch する (これで `~/.config/git/config` が権威になる)
- **lazygit** — git TUI。tmux内 `prefix g` でポップアップ
- **gh** — GitHub CLI。リポジトリ作成、PR操作等
- **delta** — diff/`git log` ビューア

### 開発環境補助
- **OrbStack** — macOS用 Docker 代替 + Linux VM。`.zprofile` でシェル統合
- **Obsidian** — Markdownノート (CLI起動用に PATH 追加)
- **Claude Code** (`.config/claude/`) — CLI本体は自前アップデータを持ち更新が速いため Nix では管理せず、ネイティブインストーラ / mise 経由の npm で導入する。設定は自作の `CLAUDE.md` (グローバル指示) / `settings.json` / `statusline-command.sh` のみ symlink。`model`・`statusLine` は共有、`enabledPlugins` 等の機械固有設定は管理外の `settings.local.json` に置く

## 管理しないもの

セキュリティや実用上の理由から、以下はリポジトリ管理外にしています:

- `~/.ssh/` — SSH秘密鍵
- `~/.claude.json` と `~/.claude/` の大部分 — セッション・履歴・認証・キャッシュ (`projects/`, `sessions/`, `history.jsonl`, `~/.claude/settings.local.json` など)。**自作設定 (`CLAUDE.md` / `settings.json` / `statusline-command.sh`) だけ**を `.config/claude/` で管理し個別に symlink する (ディレクトリ全体はリンクしない)
- `~/.config/gh/` — GitHub CLI (OAuthトークンを含む)
- `~/.config/raycast/` — マシン固有の拡張データ (約7MB)
- 履歴/キャッシュ系: `~/.zsh_history`, `~/.viminfo`, `~/.cache/`, など

## メモ

- Starshipは `~/.config/starship.toml` の直置きを避けるため、`STARSHIP_CONFIG="$XDG_CONFIG_HOME/starship/starship.toml"` を `.zshrc` で指定してサブディレクトリ管理にしています。
- miseは作業ディレクトリから `.config/mise/config.toml` をproject-level configとして検出するため、`~/dotfiles/` で作業すると未信頼エラーが出ます。初回セットアップ後に以下を実行してください:
  ```sh
  mise trust ~/dotfiles/.config/mise/config.toml
  ```
