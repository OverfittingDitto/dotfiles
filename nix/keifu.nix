# ============================================================================
# keifu - Unicode でコミットグラフを描く Git TUI ビューア
# ============================================================================
# nixpkgs 未収録のため、GitHub のソースから buildRustPackage でビルドする。
# Serie と違い画像プロトコル不要・軽量で、SSH/tmux 越しでも同じ見た目になる。
#
# ハッシュ更新手順 (バージョンを上げたときも同じ):
#   1. version を上げ、hash / cargoHash を lib.fakeHash に戻す
#   2. home-manager switch を実行 → エラーに「正しいハッシュ」が出る
#   3. それを hash / cargoHash に貼り、再度 switch
# ============================================================================
{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, perl
, stdenv
, darwin
}:

rustPlatform.buildRustPackage rec {
  pname = "keifu";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "trasta298";
    repo = "keifu";
    rev = "v${version}";
    hash = "sha256-Srw71Rswafu70kKI36dY1PtB4BQhpTYYzqbrWJuvaUM=";
  };

  cargoHash = "sha256-Ga405TV1uDSZbADrV+3aAeLDRfdPFHzdxxTEDu+f+b4=";

  # git2 が vendored-openssl 指定 = openssl をソースからビルドするため perl が要る。
  # pkg-config は libgit2-sys 用。
  nativeBuildInputs = [ pkg-config perl ];

  buildInputs = lib.optionals stdenv.isDarwin [
    darwin.apple_sdk.frameworks.Security
  ];

  meta = {
    description = "TUI tool to visualize Git commit graphs with branch genealogy";
    homepage = "https://github.com/trasta298/keifu";
    license = lib.licenses.mit;
    mainProgram = "keifu";
  };
}
