{ pkgs, lib }:
let
  src = (import ../source { inherit pkgs; });
in
pkgs.rustPlatform.buildRustPackage {
  pname = "inputmodule-control";
  version = src.rev;
  doCheck = false;
  cargoHash = "sha256-iqB0JxRlIwdjTh+dPa3W5bwYVOFGWObmBXUETZC6Rk8=";
  buildAndTestSubdir = "inputmodule-control";

  buildInputs = with pkgs; [
    systemd
  ];

  nativeBuildInputs = with pkgs; [
    pkg-config
    rustPlatform.bindgenHook
  ];

  src = src;

  meta = {
    description = "Firmware for the Framework Laptop 16 input modules, as well as the tool to control them.";
    homepage = "https://github.com/FrameworkComputer/inputmodule-rs";
    license = lib.licenses.mit;
    platform = lib.platforms.linux;
    maintainers = [ ];
  };
}
