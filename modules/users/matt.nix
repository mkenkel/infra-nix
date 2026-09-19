{ den, ... }:
{
  den.aspects.matt = {
    # (9)
    includes = [
      den.batteries.define-user
      den.batteries.primary-user
    ]; # (10)
    homeManager = { pkgs, ... }: {
      home.packages = [ pkgs.vim ];
    };
  };
}
