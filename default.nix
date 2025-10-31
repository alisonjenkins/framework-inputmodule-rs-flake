{pkgs, ...}: {
  inputmodule-control = pkgs.callPackage ./inputmodule-control {};
  udev = pkgs.callPackage ./udev {};
}
