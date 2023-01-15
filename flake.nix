{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, flake-utils, nixos-generators, ... }@attrs: 
    # Create system-specific outputs for lima systems
    let
      ful = flake-utils.lib;
    in
    ful.eachSystem [ ful.system.x86_64-linux ful.system.aarch64-linux ] (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        packages = {
          img = nixos-generators.nixosGenerate {
            inherit pkgs;
            modules = [
              ./configuration.nix
            ];
            format = "raw-efi";
          };
        };
        nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = attrs;
          modules = [
            ./configuration.nix
            ./user-config.nix
          ];
        };
      });
}