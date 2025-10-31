{ pkgs, stdenv, lib}:
let
  src = (import ../source { inherit pkgs; });
in
stdenv.mkDerivation {
  pname = "framework-inputmodules-udev-rules";
  version = src.rev;
  src = src;

  buildInputs = [ ];

  installPhase = ''
    mkdir -p $out/etc/udev/rules.d
    cp release/50-framework-inputmodule.rules $out/etc/udev/rules.d/
  '';

  meta = with lib; {
    description = "Udev rules allowing users to access the Framework 16's LED Matrix, B1 Display and C1 Minimal Microcontroller Modules";
    license = licenses.mit;
    maintainers = [ ];
    platforms = platforms.linux;
  };
}
