{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {  # "nixos" matches your hostname
      system = "x86_64-linux";
      modules = [
        ./hardware-configuration.nix  # Hardware-specific
        ./configuration.nix           # Main config
      ];
    };
  };
}
