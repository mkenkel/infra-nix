{ lib, den, ... }:
{
  den.schema.user.classes = lib.mkDefault [ "homeManager" ]; # (2)
  den.default.homeManager.home.stateVersion = "25.11"; # (3)
}
