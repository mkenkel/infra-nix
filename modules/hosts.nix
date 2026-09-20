# defines all hosts + users + homes.
# then config their aspects in as many files you want
{
  # tux user at igloo host.
  den.hosts.x86_64-linux.igloo.users.matt = {}; # (4) (5)

  # define an standalone home-manager for tux
  # den.homes.x86_64-linux.tux = { };

  # matt user at mktogo host (MacBook, nix-darwin).
  den.hosts.aarch64-darwin.mktogo.users.matt = {};

  # other hosts can also have user tux.
  # den.hosts.x86_64-linux.south = {
  #   wsl = { }; # add nixos-wsl input for this.
  #   users.tux = { };
  #   users.orca = { };
  # };
}
