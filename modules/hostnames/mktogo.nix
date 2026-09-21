{
  den,
  inputs,
  ...
}: {
  den.aspects.mktogo = {
    includes = [
      den.batteries.hostname
    ];
    darwin = {pkgs, ...}: {
      imports = [inputs.nix-homebrew.darwinModules.nix-homebrew];

      nixpkgs.hostPlatform = "aarch64-darwin";
      nixpkgs.config.allowUnfree = true;

      # nix-darwin only manages an existing account's shell/home when it's a
      # known user with a matching uid (see den.batteries.user-shell).
      users.knownUsers = ["matt"];
      users.users.matt.uid = 501;

      nix.enable = true;
      nix.settings.experimental-features = ["nix-command" "flakes"];

      nix-homebrew = {
        user = "matt";
        enable = true;
        enableRosetta = true; # x86 App Compatibility
        taps = {
          "homebrew/homebrew-bundle" = inputs.homebrew-bundle;
          "homebrew/homebrew-cask" = inputs.homebrew-cask;
          "homebrew/homebrew-core" = inputs.homebrew-core;
        };
        mutableTaps = false;
      };

      homebrew = {
        enable = true;
        casks = [
          "autodesk-fusion"
          "firefox"
          "font-sarasa-nerd"
          "keeper-password-manager"
          "obsidian"
          "visual-studio-code"
          "spotify"
          "raycast"
          "whisky"
        ];
      };

      environment.systemPackages = with pkgs; [
        chafa
        nixfmt
        alejandra
      ];

      system = {
        defaults = {
          NSGlobalDomain.AppleInterfaceStyle = "Dark";

          dock = {
            autohide = true;
            show-recents = false;
            launchanim = true;
            mouse-over-hilite-stack = true;
            orientation = "bottom";
            tilesize = 48;
          };

          finder._FXShowPosixPathInTitle = false;

          trackpad = {
            Clicking = true;
            TrackpadThreeFingerDrag = true;
          };

          universalaccess.reduceTransparency = true;
        };

        keyboard = {
          enableKeyMapping = true;
          remapCapsLockToControl = true;
        };

        stateVersion = 5;
        startup.chime = false;
      };
    };
  };
}
