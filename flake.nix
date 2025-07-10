{
  description = "Server software for personal website.";

  inputs = {
    nixpkgs.url = "github:Nixos/nixpkgs/nixos-25.05";
    flake-utils.url = "github:/numtide/flake-utils";
    cl-nix-lite.url = "github:hraban/cl-nix-lite";
  };

  outputs = inputs @ { self, nixpkgs, flake-utils, cl-nix-lite }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = nixpkgs.legacyPackages.${system}.extend cl-nix-lite.overlays.default;
      name = "personal-website";
      version = "1.0";
    in {
      packages = {
        default = import ./package.nix {
          inherit pkgs name version;
          web-server = pkgs.fetchFromGitHub {
            owner = "ChristopherSegale";
            repo = "serve-website";
            rev = "bb64154";
            hash = "sha256-aWkFlLxJln93GVs+qBYXdX1+/ccVUe8zxAWkBpsKJAU=";
          };
          contents = pkgs.fetchFromGitHub {
            owner = "ChristopherSegale";
            repo = "personal-website";
            rev = "2f284cf";
            hash = "sha256-MZ5OvLALRwYqsbZZDDkcA9S2PWvPnNvl2XFpDU9fZhU=";
          };
          scriptName = "run-server";
        };
        meta.license = pkgs.lib.licenses.mit;
      };
    });
}
