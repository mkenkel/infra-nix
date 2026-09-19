{den, ...}: let
  starshipHomeManager = {
    programs.starship = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        add_newline = true;
        format = "$time\n$all";

        battery = {
          full_symbol = "🔋 ";
          charging_symbol = "⚡️ ";
          discharging_symbol = "⚛  ";
          format = "[$symbol$percentage]($style) ";
          display = [
            {
              threshold = 10;
              style = "bold red";
            }
            {
              threshold = 30;
              style = "bold yellow";
              discharging_symbol = "💦";
            }
            {
              threshold = 100;
              style = "bold green";
            }
          ];
        };

        character = {
          success_symbol = " [➜](bold green) ";
          error_symbol = " [✗](bold red) ";
          vicmd_symbol = "[V](bold green) ";
        };

        aws.symbol = "  ";
        buf.symbol = " ";
        c.symbol = " ";
        conda.symbol = " ";
        dart.symbol = " ";
        directory.read_only = " ";
        docker_context.symbol = " ";
        elixir.symbol = " ";
        elm.symbol = " ";
        fossil_branch.symbol = " ";
        git_branch.symbol = " ";
        golang.symbol = " ";
        guix_shell.symbol = " ";
        haskell.symbol = " ";
        haxe.symbol = "⌘ ";
        hg_branch.symbol = " ";
        hostname.ssh_symbol = " ";
        java.symbol = " ";
        julia.symbol = " ";
        lua.symbol = " ";
        memory_usage.symbol = " ";
        meson.symbol = "喝 ";
        nim.symbol = " ";
        nix_shell.symbol = " ";
        nodejs.symbol = " ";

        os.symbols = {
          Alpine = " ";
          Amazon = " ";
          Android = " ";
          Arch = " ";
          CentOS = " ";
          Debian = " ";
          DragonFly = " ";
          Emscripten = " ";
          EndeavourOS = " ";
          Fedora = " ";
          FreeBSD = " ";
          Garuda = "﯑ ";
          Gentoo = " ";
          HardenedBSD = "ﲊ ";
          Illumos = " ";
          Linux = " ";
          Macos = " ";
          Manjaro = " ";
          Mariner = " ";
          MidnightBSD = " ";
          Mint = " ";
          NetBSD = " ";
          NixOS = " ";
          OpenBSD = " ";
          openSUSE = " ";
          OracleLinux = " ";
          Pop = " ";
          Raspbian = " ";
          Redhat = " ";
          RedHatEnterprise = " ";
          Redox = " ";
          Solus = "ﴱ ";
          SUSE = " ";
          Ubuntu = " ";
          Unknown = " ";
          Windows = " ";
        };

        package.symbol = " ";
        pijul_channel.symbol = "🪺 ";
        python.symbol = " ";
        rlang.symbol = "ﳒ ";
        ruby.symbol = " ";
        rust.symbol = " ";
        scala.symbol = " ";
        spack.symbol = "🅢 ";

        time = {
          disabled = false;
          format = "[$time ]($style)";
          time_format = "%r";
          utc_time_offset = "-4";
          style = "dimmed white";
        };
      };
    };
  };
in {
  den.aspects.starship-config = {
    includes = [
      ({
        host,
        user,
        ...
      }: {
        name = "starship-config/${user.userName}@${host.name}";
        homeManager = starshipHomeManager;
      })
    ];
  };
}
