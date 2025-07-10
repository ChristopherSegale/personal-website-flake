{pkgs, name, version, scriptName }:

let
  contents = pkgs.fetchFromGitHub {
    owner = "ChristopherSegale";
    repo = "personal-website";
    rev = "2f284cf";
    hash = "sha256-MZ5OvLALRwYqsbZZDDkcA9S2PWvPnNvl2XFpDU9fZhU=";
  };
in pkgs.lispPackagesLite.lispDerivation rec {
  pname = name;
  inherit version scriptName;
  buildInputs = with pkgs; [ openssl_3 ];
  lispSystem = "serve-website";
  lispDependencies = with pkgs.lispPackagesLite; [
    bordeaux-threads
    hunchentoot
    cl-who
  ];
  src = pkgs.fetchFromGitHub {
    owner = "ChristopherSegale";
    repo = "serve-website";
    rev = "bb64154";
    hash = "sha256-aWkFlLxJln93GVs+qBYXdX1+/ccVUe8zxAWkBpsKJAU=";
  };
  patches = [ ./personal-website.patch ];
  installPhase = ''
    mkdir -p $out/bin
    mkdir -p $out/var/serve-website
    echo "#!${pkgs.runtimeShell}" >> $out/bin/${scriptName}
    printf "cd %s\n" $out/var/serve-website >> $out/bin/${scriptName}
    echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${pkgs.lib.makeLibraryPath buildInputs} ./serve-website" >> $out/bin/${scriptName}
    chmod 0555 $out/bin/${scriptName}
    cp serve-website $out/var/serve-website
    cp -r web-resources $out/var/serve-website
    cp -r ${contents}/web-resources/* $out/var/serve-website/web-resources
  '';
}
