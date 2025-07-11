{ pkgs, package }:

pkgs.dockerTools.buildImage {
  name = "personal-website";
  tag = "1.0";
  created = "now";
  copyToRoot = pkgs.buildEnv {
    name = "image-root";
    paths = [ pkgs.dockerTools.fakeNss package ];
    pathsToLink = [ "/bin" "/etc" "/var" ];
  };
  config = {
    Cmd = [ "${package}/bin/run-server" ];
    ExposedPorts = {
      "80" = {};
    };
  };
}
