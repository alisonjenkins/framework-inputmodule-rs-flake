{
  description = "NixOS packages for the Framework inputmodules-rs repo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      pkgsFor = forAllSystems (system:
        import nixpkgs {
          inherit system;
        }
      );
    in
    {
      legacyPackages = forAllSystems (system:
        (import ./default.nix) pkgsFor.${system}
      );

      packages = forAllSystems (system:
        (import ./default.nix) pkgsFor.${system}
      );

      homeManagerModules = {
        inputmodule-control = import ./home-manager-module.nix;
        default = self.homeManagerModules.inputmodule-control;
      };
    };
}
