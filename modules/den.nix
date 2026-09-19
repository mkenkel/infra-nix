{ inputs, den, lib, ... }: {
  imports = [ inputs.den.flakeModule ]; # (1)

  den.schema.user.classes = lib.mkDefault [ "homeManager" ]; # (2)

  den.default.homeManager.home.stateVersion = "25.11"; # (3)

  den.hosts.x86_64-linux.igloo.users.matt = {}; # (4) (5)

  den.aspects.igloo = { # (6)
    includes = [ den.batteries.hostname ]; # (7)
    nixos = { pkgs, ... }: {
      imports = [ ./_nixos/configuration.nix ]; # (8)
      environment.systemPackages = [ pkgs.hello ];
    };
  };

  den.aspects.matt = { # (9)
    includes = [ den.batteries.define-user den.batteries.primary-user ]; # (10)
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.vim ];
    };
  };
}
