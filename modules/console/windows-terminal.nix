{den, ...}: let
  # The Windows account that owns the Windows Terminal install (not the WSL
  # user), as it appears under C:\Users.
  windowsUser = "Matthew";

  # Kitty-style font zoom (ctrl+shift +/-/0), since kitty isn't the terminal
  # on WSL hosts.
  desired = {
    actions = [
      {
        id = "User.fontUp";
        command = {
          action = "adjustFontSize";
          delta = 1;
        };
      }
      {
        id = "User.fontDown";
        command = {
          action = "adjustFontSize";
          delta = -1;
        };
      }
      {
        id = "User.fontReset";
        command = "resetFontSize";
      }
    ];
    keybindings = [
      {
        id = "User.fontUp";
        keys = "ctrl+shift+plus";
      }
      {
        id = "User.fontDown";
        keys = "ctrl+shift+minus";
      }
      {
        id = "User.fontReset";
        keys = "ctrl+shift+0";
      }
    ];
  };

  windowsTerminalHomeManager = {
    pkgs,
    lib,
    ...
  }: {
    # settings.json lives on the Windows side and Windows Terminal rewrites it
    # (new profiles, UI edits), so this jq-merges only our actions/keybindings
    # in rather than owning the file. Existing entries with the same id or the
    # same keys are replaced, so re-running is idempotent and everything else
    # survives. Skipped if Windows Terminal isn't installed.
    home.activation.windowsTerminalSettings = lib.hm.dag.entryAfter ["writeBoundary"] ''
      settingsFile="/mnt/c/Users/${windowsUser}/AppData/Local/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json"
      desired=${lib.escapeShellArg (builtins.toJSON desired)}
      if [ -f "$settingsFile" ]; then
        merged=$(${lib.getExe pkgs.jq} --argjson d "$desired" '
          ($d.actions | map(.id)) as $aids
          | ($d.keybindings | map(.id)) as $kids
          | ($d.keybindings | map(.keys)) as $keys
          | .actions = ((.actions // []) | map(select(.id as $i | $aids | index($i) | not))) + $d.actions
          | .keybindings = ((.keybindings // []) | map(select((.id as $i | $kids | index($i) | not) and (.keys as $k | $keys | index($k) | not)))) + $d.keybindings
        ' "$settingsFile") || { echo "windowsTerminalSettings: could not parse $settingsFile, leaving it alone" >&2; merged=""; }
        if [ -n "$merged" ] && [ "$merged" != "$(${lib.getExe pkgs.jq} . "$settingsFile")" ]; then
          if [ -n "''${DRY_RUN_CMD:-}" ]; then
            echo "Would merge font keybinds into $settingsFile"
          else
            printf '%s\n' "$merged" > "$settingsFile"
          fi
        fi
      fi
    '';
  };
in {
  den.aspects.windows-terminal = {
    includes = [
      ({
        host,
        user,
        ...
      }: {
        name = "windows-terminal/${user.userName}@${host.name}";
        homeManager = windowsTerminalHomeManager;
      })
    ];
  };
}
