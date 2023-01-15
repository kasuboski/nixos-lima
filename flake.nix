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
              ./lima.nix
            ];
            format = "raw-efi";
          };
        };
      }) // { 
        nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux"; # doesn't play nice with each system :shrug:
          specialArgs = attrs;
          modules = [
            ./lima.nix
            ./user-config.nix
          ];
        };
      };
}