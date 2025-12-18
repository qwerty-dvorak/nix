{ inputs }:

final: prev:
let
  # Helper function to import a package
  callPackage = prev.lib.callPackageWith (prev // packages // inputs);

  # Define all packages
  packages = {
    # Hyde core packages
    hyde-gallery = callPackage ./hyde-gallery.nix { };
    # Additional packages
    pokego = callPackage ./pokego.nix { };
    go = prev.go.overrideAttrs (old: rec {
      version = "1.25.5";
      src = prev.fetchurl {
        url = "https://go.dev/dl/go${version}.src.tar.gz";
        sha256 = "0kwm3af45rg8a65pbhsr3yv08a4vjnwhcwakn2hjikggj45gv992"; 
      };
      doCheck = false; # Skip tests to speed up build
    });

    python-pyamdgpuinfo = callPackage ./python-pyamdgpuinfo.nix { };
    Tela-circle-dracula = callPackage ./Tela-circle-dracula.nix { };
    Bibata-Modern-Ice = callPackage ./Bibata-Modern-Ice.nix { };
    hyde = callPackage ./hyde.nix { inherit inputs; };
    hydenix-themes = callPackage ./themes/default.nix { };
    hyq = inputs.hyq.packages.${prev.system}.default;
    hydectl = inputs.hydectl.packages.${prev.system}.default;
    hyde-ipc = inputs.hyde-ipc.packages.${prev.system}.default;
    hyde-config = inputs.hyde-config.packages.${prev.system}.default;
  };
in
packages
