{ den, ... }:
{
  den.aspects.igloo = {
    # (6)
    includes = [ den.batteries.hostname ]; # (7)
    nixos = { pkgs, ... }: {
      imports = [ ./_nixos/configuration.nix ]; # (8)
      environment.systemPackages = [ pkgs.hello ];
    };
  };
}
