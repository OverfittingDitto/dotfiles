{
  description = "home-manager configuration (packages + dotfile symlinks)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      # マシン固有値はリポジトリに書かず、switch 実行時 (--impure) に環境から読む。
      #   system : builtins.currentSystem  (例: aarch64-darwin / x86_64-linux)
      #   user   : $USER
      #   home   : $HOME
      # これらは --impure を付けたときだけ解決される (= pure eval では使えない)。
      system = builtins.currentSystem;
    in {
      # 使い方:  home-manager switch --flake ~/dotfiles#default --impure
      homeConfigurations.default = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system};
        modules = [
          ./nix/common.nix
          {
            home.username = builtins.getEnv "USER";
            home.homeDirectory = builtins.getEnv "HOME";
            # home-manager のリリース互換マーカー。初回設定後は変更しない。
            home.stateVersion = "26.05";
            programs.home-manager.enable = true;
          }
        ];
      };
    };
}
