{inputs, ...}: {
  imports = [
    (inputs.flake-file.flakeModules.dendritic or {})
    (inputs.den.flakeModules.dendritic or {})
  ];

  # other inputs may be defined at a module using them.
  flake-file.inputs = {
    den.url = "github:denful/den";
    flake-file.url = "github:vic/flake-file";

    nixpkgs.url = "github:nixos/nixpkgs/release-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mango = {
      url = "github:mangowm/mango";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mangobar = {
      url = "github:mangowm/mangobar";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    refind-theme-regular = {
      url = "github:bobafetthotmail/refind-theme-regular";
      flake = false;
    };
  };
}
