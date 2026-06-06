# ============================================================================
# 共有 home-manager モジュール (マシン非依存)
# ============================================================================
#
# ここには「どのパッケージを入れるか」と「どの設定ファイルを symlink するか」
# だけを書く。ユーザー名・ホームディレクトリ・アーキテクチャ等のマシン固有値は
# 一切書かない (それらは各マシンの init 生成ファイルが持つ)。
#
# symlink は home-manager の通常動作 (Nix ストアへコピー) ではなく
# mkOutOfStoreSymlink を使い、リポジトリの実ファイルへ直接リンクする。
# これにより setup.sh とまったく同じ挙動になり、ファイルを編集したら
# 再ビルドなしで即反映される。
# ============================================================================
{ config, pkgs, lib, ... }:

let
  # リポジトリの場所。README の手順どおり ~/dotfiles に clone した前提。
  # 別の場所に置く場合はここだけ変更する。
  dotfilesDir = "${config.home.homeDirectory}/dotfiles";

  # リポジトリ内の相対パスを、リポジトリ実体への out-of-store symlink に変換する。
  link = path: config.lib.file.mkOutOfStoreSymlink "${dotfilesDir}/${path}";
in
{
  # --- インストールするパッケージ ------------------------------------------
  # 旧 Homebrew formula のうち、ライブラリ依存 (libgit2 等) を除いた実ツール。
  # trash は nixpkgs 未収録のため Homebrew に据え置き (macOS 専用)。
  home.packages = with pkgs; [
    # シェル / プロンプト
    zsh          # 標準シェル (macOSは同梱だが Linux/WSL は別途必要)
    sheldon      # zsh プラグインマネージャ
    starship     # プロンプト
    zoxide       # cd の代替

    # エディタ
    neovim

    # マルチプレクサ
    tmux

    # Git
    git
    gh           # GitHub CLI
    ghq          # リポジトリ管理
    delta        # git-delta: diff ビューア
    lazygit      # git TUI

    # ファイル操作
    eza          # ls の代替
    fd           # find の代替
    dust         # du の代替
    bat          # cat の代替
    hexyl        # hex ビューア
    tree

    # 検索
    ripgrep      # rg
    fzf

    # システムモニタ
    bottom       # btm: top の代替 (.zshrc で top にエイリアス)
    procs        # ps の代替
    pstree

    # 開発補助
    mise         # ランタイムバージョン管理 (usage は mise の依存として付随)
    tealdeer     # tldr
    jq           # JSON 処理 (Claude Code の statusline スクリプトが依存)

    # システム情報表示。素の fastfetch は efl/SDL/pipewire/imagemagick 等の
    # GUI・マルチメディア依存を大量に引き込み closure が約1.7GBになる。CLIバナー
    # 用途では不要なので重いバックエンドを無効化する (closure 約0.3GBに削減)。
    (fastfetch.override {
      enlightenmentSupport = false;  # efl→SDL→pipewire/openal/gtk4 連鎖を断つ(最大要因)
      imageSupport         = false;  # imagemagick / chafa
      vulkanSupport        = false;
      openglSupport        = false;
      waylandSupport       = false;
      x11Support           = false;
      audioSupport         = false;
      openclSupport        = false;
      ddcutil              = null;   # 輝度センサ(ddc)系を除外
    })

    # Neovim treesitter のパーサビルド用ツールチェーン。
    # nvim 0.12 の nvim-treesitter (main) は `tree-sitter build` でパーサを
    # コンパイルするため、tree-sitter CLI と C コンパイラの両方が必要。
    # 無いと :TSInstall が失敗する (同梱パーサのみ動作)。Mac の brew 構成と同じ。
    tree-sitter  # パーサ生成/ビルド CLI
    gcc          # パーサのコンパイラ (cc を提供)

    # Nix
    nix-tree     # 依存関係ツリーの可視化 (TUI)
  ]
  ++ lib.optionals pkgs.stdenv.isDarwin [
    # macOS 専用ツールがあればここ (trash は nixpkgs 未収録なので brew のまま)
  ]
  ++ lib.optionals pkgs.stdenv.isLinux [
    # Linux / WSL 専用ツールがあればここ
  ];

  # --- ~/.config/<name> への symlink ---------------------------------------
  # setup.sh の「.config/<name>/ をディレクトリごとリンク」に対応。
  # GUI アプリ (alacritty/ghostty/zed) はヘッドレスな SSH/WSL では使わないが、
  # リンクしても実害はない (実ファイルを指すだけ)。不要なら行を削除する。
  xdg.configFile = {
    "alacritty".source = link ".config/alacritty";
    "fzf".source       = link ".config/fzf";
    "ghostty".source   = link ".config/ghostty";
    "mise".source      = link ".config/mise";
    "nvim".source      = link ".config/nvim";
    "sheldon".source   = link ".config/sheldon";
    "starship".source  = link ".config/starship";
    "tmux".source      = link ".config/tmux";
    "zed".source       = link ".config/zed";
  };

  # --- ホーム直下への symlink ----------------------------------------------
  # setup.sh の LINK_TO_HOME (zsh / vim) に対応。
  home.file = {
    ".zshrc".source    = link ".config/zsh/.zshrc";
    ".zprofile".source = link ".config/zsh/.zprofile";
    ".vimrc".source    = link ".config/vim/.vimrc";

    # Claude Code は自前アップデータを持つためバイナリは Nix で管理しない
    # (ネイティブ / mise 経由)。ただし自作の設定ファイルだけはここで symlink する。
    # ~/.claude/ には履歴・セッション・認証等が同居するので、ディレクトリ全体では
    # なく自作ファイルのみを個別にリンクする。機械固有設定 (enabledPlugins 等) は
    # 管理対象外の ~/.claude/settings.local.json に置く (Claude が自動マージ)。
    ".claude/CLAUDE.md".source             = link ".config/claude/CLAUDE.md";
    ".claude/settings.json".source         = link ".config/claude/settings.json";
    ".claude/statusline-command.sh".source = link ".config/claude/statusline-command.sh";
  };

  # --- ロケールを必要言語だけに絞る -----------------------------------------
  # home-manager は LOCALE_ARCHIVE 用に全ロケール(約222MB)を入れる。使う言語
  # だけに絞って closure を削減する。LOCALE_ARCHIVE の設定自体は home-manager が
  # Linux 限定で行い、この値は Darwin では遅延されて評価されない (glibcは未ビルド)。
  i18n.glibcLocales = pkgs.glibcLocales.override {
    allLocales = false;
    locales = [ "en_US.UTF-8/UTF-8" "ja_JP.UTF-8/UTF-8" "C.UTF-8/UTF-8" ];
  };
}
