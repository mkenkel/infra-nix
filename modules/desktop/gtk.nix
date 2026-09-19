{den, ...}: let
  gtkHomeManager = {pkgs, ...}: {
    gtk = {
      enable = true;
      colorScheme = "light";
      theme = {
        name = "Breeze-light";
        package = pkgs.kdePackages.breeze;
      };
      cursorTheme = {
        name = "Posy_Cursor_125_175";
        package = pkgs.posy-cursors;
        size = 48;
      };
      gtk3 = {
        extraConfig = {
          Settings = ''
            gtk-application-prefer-dark-theme=0
            gtk-dialogs-use-header=false
          '';
          extraCss = ''
            headerbar.default-decoration {
              margin-bottom: 50px;
              margin-top: -100px;
            }
            window.csd,             /* gtk4? */
            window.csd decoration { /* gtk3 */
              box-shadow: none;
            }
          '';
        };
      };
      gtk4 = {
        theme = null;
        extraConfig = {
          Settings = ''
            gtk-application-prefer-dark-theme=0
            gtk-dialogs-use-header=false
          '';
        };
        extraCss = ''
          headerbar.default-decoration {
            margin-bottom: 50px;
            margin-top: -100px;
          }
          window.csd,             /* gtk4? */
          window.csd decoration { /* gtk3 */
            box-shadow: none;
          }
        '';
      };
      font = {
        name = "Monaspace Neon NF";
        package = pkgs.monaspace;
        size = 12;
      };
    };
  };
in {
  den.aspects.gtk = {
    # home-manager's gtk module mirrors theme/cursor/font settings into dconf
    # (org/gnome/desktop/interface); dconf's D-Bus service must be registered
    # system-wide or activation fails with "ServiceUnknown: not activatable".
    nixos.programs.dconf.enable = true;
    includes = [
      # Posy cursors are CC-BY-NC-4.0 (unfree); scope the allowance to just
      # this package rather than enabling allowUnfree globally.
      (den.batteries.unfree ["posy-cursors"])
      ({
        host,
        user,
        ...
      }: {
        name = "gtk/${user.userName}@${host.name}";
        homeManager = gtkHomeManager;
      })
    ];
  };
}
