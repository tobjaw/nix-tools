{
  description = "Entrypoint for various Nix modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      git-hooks,
      devshell,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { flake-parts-lib, ... }:
      let
        inherit (flake-parts-lib) importApply;
        importFlakeModule =
          p:
          importApply p {
            inherit flake-parts-lib;
            inherit (inputs) nixpkgs-lib;
          };
        defaultModule = importFlakeModule ./flake-modules/default.nix;
      in
      {
        # dogfood flake modules for this flake
        imports = [
          defaultModule
          git-hooks.flakeModule
          devshell.flakeModule
        ];
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ];
        flake.flakeModules = {
          git-hooks = git-hooks.flakeModule;
          devshell = devshell.flakeModule;
          default = defaultModule;
          go = importFlakeModule ./flake-modules/go.nix;
          javascript = importFlakeModule ./flake-modules/javascript.nix;
        };
        perSystem =
          {
            config,
            ...
          }:
          {
            devshells.default = {
              commands = [
                {
                  name = "lint";
                  help = "lint project";
                  command = "nix flake check";
                }
              ];
              devshell.startup.pre-commit.text = ''
                ${config.pre-commit.installationScript}
              '';
            };
          };
      }
    );

}
