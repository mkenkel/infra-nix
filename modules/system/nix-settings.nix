{
  den.aspects.nix-settings = {
    nixos = {
      nix.settings.experimental-features = ["nix-command" "flakes"];
      nix.gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      };
    };
    darwin = {
      # nix-darwin removed `nix.gc.dates` (use `interval`) and has no
      # `nix.settings.auto-optimise-store` equivalent of the nixos side —
      # `nix.optimise.automatic` is the supported way to dedupe the store.
      nix.gc = {
        automatic = true;
        interval = [
          {
            Weekday = 7;
            Hour = 3;
            Minute = 15;
          }
        ];
        options = "--delete-older-than 30d";
      };
      nix.optimise.automatic = true;
    };
  };
}
