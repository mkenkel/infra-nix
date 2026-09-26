# defines all hosts + users + homes.
# then config their aspects in as many files you want
{
  # tux user at igloo host.
  den.hosts.x86_64-linux.igloo.users.matt = {}; # (4) (5)

  # define an standalone home-manager for tux
  # den.homes.x86_64-linux.tux = { };

  # matt user at mktogo host (MacBook, nix-darwin).
  den.hosts.aarch64-darwin.mktogo.users.matt = {};

  # matt user at updog host (NixOS-WSL on the Windows desktop).
  den.hosts.x86_64-linux.updog = {
    wsl.enable = true;
    users.matt = {};
  };
}
