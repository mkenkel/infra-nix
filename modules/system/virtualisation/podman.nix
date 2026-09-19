{
  den.aspects.virt-podman.nixos = {
    virtualisation.containers.enable = true;
    virtualisation.podman.enable = false;
    virtualisation.podman.dockerCompat = true;
    virtualisation.podman.defaultNetwork.settings.dns_enabled = true;
  };
}
