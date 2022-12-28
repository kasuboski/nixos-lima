{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nixos-generators, ... }: {
    packages.x86_64-linux = {
      box = nixos-generators.nixosGenerate {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./configuration.nix
        ];
        format = "raw-efi";
      };
    };
    packages.aarch64-linux = {
      box = nixos-generators.nixosGenerate {
        pkgs = nixpkgs.legacyPackages.aarch64-linux;
        modules = [
          ./configuration.nix
        ];
        format = "raw-efi";
      };
    };
  };
}