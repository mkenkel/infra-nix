{
  den.aspects.nix-settings = {
    nixos = {
      nix.settings.experimental-features = ["nix-command" "flakes"];
      # numtide's cache for llm-agents.nix (workmux, claude-code, etc.) —
      # avoids compiling those from source on every host.
      nix.settings.extra-substituters = ["https://cache.numtide.com"];
      nix.settings.extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
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
      nix.settings.extra-substituters = ["https://cache.numtide.com"];
      nix.settings.extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
    };
  };
}
