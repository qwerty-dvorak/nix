{
  inputs,
  ...
}:
let
  system = "x86_64-linux";
  pkgs = import inputs.nixpkgs {
    inherit system;
    config = {
      allowUnfree = true;
      permittedInsecurePackages = [
        "ventoy-1.1.07"
      ];
    };
    overlays = [
      inputs.self.overlays.default
    ];
  };
in
{

  nixpkgs.pkgs = pkgs;

  imports = [
    inputs.home-manager.nixosModules.home-manager
    ./hardware-configuration.nix
    inputs.self.nixosModules.default
    inputs.nixos-hardware.nixosModules.common-cpu-intel
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.nixos-hardware.nixosModules.common-pc-ssd
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit inputs;
    };

    users."hydenix" =
      { ... }:
      {
        imports = [
          inputs.self.homeModules.default
          ./home.nix
        ];
      };
  };

  hydenix = {
    enable = true;
    hostname = "hydenix";
    timezone = "Asia/Kolkata";
    locale = "en_CA.UTF-8";
  };

  users.users.hydenix = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "docker"
    ];
    shell = pkgs.zsh;
  };

  virtualisation.docker.enable = true;

  system.stateVersion = "25.05";
}
