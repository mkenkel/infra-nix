{den, inputs, ...}: let
  mangoHomeManager = {
    imports = [inputs.mango.hmModules.mango];
    wayland.windowManager.mango.enable = true;
  };
in {
  den.aspects.mango = {
    homeManager = mangoHomeManager;
    nixos = {
      imports = [inputs.mango.nixosModules.mango];
      programs.mango.enable = true;
    };
  };
}
