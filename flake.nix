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
      buildInputs = with pkgs; [ openssl_3 ];
      scriptName = "run-server";
    in {
      packages = {
        default = pkgs.lispPackagesLite.lispDerivation {
          pname = name;
          version = "1.0";
          inherit buildInputs;
          lispSystem = "serve-website";
          lispDependencies = with pkgs.lispPackagesLite; [
            bordeaux-threads
            hunchentoot
            cl-who
          ];
          src = web-server;
          patches = [ ./personal-website.patch ];
          installPhase = ''
            mkdir -p $out/bin
            echo "#!${pkgs.runtimeShell}" >> $out/bin/${scriptName}
            printf "cd %s\n" $out >> $out/bin/${scriptName}
            echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.lib.makeLibraryPath buildInputs} ./serve-website" >> $out/bin/${scriptName}
            chmod 0555 $out/bin/${scriptName}
            cp serve-website $out
            cp -r web-resources $out
            cp -r ${contents}/web-resources/* $out/web-resources
          '';
        };
        meta.license = pkgs.lib.licenses.mit;
      };
    });
}
