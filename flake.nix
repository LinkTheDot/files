{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-wsl = {
      url = "github:nix-community/NixOS-WSL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixos-wsl, home-manager, nix-darwin, nur, ... }@inputs:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-darwin" ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (system: import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          nur.overlays.default
          (final: prev:
            let
              version = "2.1.214";
              platformAttrs = {
                "x86_64-linux" = {
                  key = "linux-x64";
                  hash = "sha256-PAKRNvfIH1TtSjjp1S5lWq1TZDPbveUFGcjDG7ZGrRQ=";
                };
                "aarch64-darwin" = {
                  key = "darwin-arm64";
                  hash = "sha256-WXlt0Y6dd/ElbzZ9ttKM5L2c1ZaOQCrToyeqw2q8bew=";
                };
              };
              system = prev.stdenv.hostPlatform.system;
              attrs = platformAttrs.${system} or null;
            in
            prev.lib.optionalAttrs (attrs != null) {
              claude-code = prev.claude-code-bin.overrideAttrs (old: {
                inherit version;
                src = prev.fetchurl {
                  url = "https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases/${version}/${attrs.key}/claude";
                  inherit (attrs) hash;
                };
              });
            })
        ];
      });

      userInfo = {
        username = "looank";
        fullName = "looank";
        userEmail = "linkthedot@users.noreply.github.com";
        gpgKey = "";
      };

      mkSystemConfig = name: { hostName = name; computerName = name; };

      # Helper: build userConfig from system type
      mkUserConfig = { system }:
        let
          homeBase =
            if builtins.elem system [ "aarch64-darwin" "x86_64-darwin" ]
            then "/Users" else "/home";
        in
        userInfo // {
          homeDirectory = "${homeBase}/${userInfo.username}";
          dotfilesPath = "${homeBase}/${userInfo.username}/.dotfiles";
        };

      mkHome = { name, system }:
        let
          isDarwin = builtins.elem system [ "aarch64-darwin" "x86_64-darwin" ];
          osSpecificModules =
            if isDarwin then [
              ./modules/home/darwin.nix
            ] else [
              ./modules/home/linux.nix
            ];
        in
        home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgsFor.${system};
          modules = osSpecificModules ++ [
            ./modules/home/default.nix
            ./modules/machines/${name}/home.nix
          ];
          extraSpecialArgs = {
            inherit inputs;
            userConfig = mkUserConfig { inherit system; };
            systemConfig = mkSystemConfig name;
            sourceRoot = self;
          };
        };

      mkDarwinSystem = name:
        nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./modules/system/darwin/default.nix
            ./modules/machines/${name}/system.nix
          ];
          specialArgs = {
            inherit inputs;
            userConfig = mkUserConfig { system = "aarch64-darwin"; };
            systemConfig = mkSystemConfig name;
            sourceRoot = self;
          };
        };
    in
    {
      homeConfigurations = {
        "workmac" = mkHome { name = "macbook"; system = "aarch64-darwin"; };
        "looank" = mkHome { name = "loonkuter"; system = "x86_64-linux"; };
      };

      darwinConfigurations = {
        "workmac" = mkDarwinSystem "macbook";
      };

      nixosConfigurations = {
        "loonkuter" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            nixos-wsl.nixosModules.default
            # ./modules/system/nixos/default.nix <- Clean this and switch to this default
            ./modules/machines/loonkuter/system.nix
          ];
          specialArgs = {
            inherit inputs;
            userConfig = mkUserConfig { system = "x86_64-linux"; };
            systemConfig = mkSystemConfig "loonkuter";
            sourceRoot = self;
          };
        };
      };
    };
}
