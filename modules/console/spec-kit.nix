{den, ...}: let
  specKitHomeManager = {pkgs, ...}: {
    # Provides the `specify` CLI (GitHub Spec Kit). Per-project scaffolding is
    # still done with `specify init`, which writes .specify/ and the agent
    # slash commands into the project, not into this config.
    home.packages = [pkgs.spec-kit];
  };
in {
  den.aspects.spec-kit = {
    includes = [
      ({
        host,
        user,
        ...
      }: {
        name = "spec-kit/${user.userName}@${host.name}";
        homeManager = specKitHomeManager;
      })
    ];
  };
}
