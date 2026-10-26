{
  description = "Cutefish desktop environment for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];

      # The desktop manager module references `pkgs.cutefish`, which is
      # provided here through `nixpkgs.overlays` from ./packages.
      cutefishModule =
        { config, lib, pkgs, ... }:
        {
          nixpkgs.overlays = [
            (final: prev: {
              cutefish = import ./packages { pkgs = final; };
            })
          ];

          imports = [
            ./nixos-modules/cutefish.nix
            ./nixos-modules/dm.nix
            ./nixos-modules/artwork.nix
          ];
        };
    in
    {
      nixosModules = {
        cutefish = cutefishModule;
        default = cutefishModule;
      };
    }
    // flake-utils.lib.eachSystem systems
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};

          cutefish = import ./packages { inherit pkgs; };
          isDerivation = value: (builtins.tryEval (value.type or null)).value == "derivation";
        in
        {
          packages = pkgs.lib.filterAttrs (_: isDerivation) cutefish;
          legacyPackages.cutefish = cutefish;
        });
}
