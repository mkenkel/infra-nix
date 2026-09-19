# defines all hosts + users + homes.
# then config their aspects in as many files you want
{
  # matt user at nixy host.
  den.hosts.x86_64-linux.nixy.users.matt = { };

  # define an standalone home-manager for matt
  # den.homes.x86_64-linux.matt = { };

  # be sure to add nix-darwin input for this:
  # den.hosts.aarch64-darwin.apple.users.alice = { };

  # other hosts can also have user matt.
  # den.hosts.x86_64-linux.south = {
  #   wsl = { }; # add nixos-wsl input for this.
  #   users.matt = { };
  #   users.orca = { };
  # };
}
