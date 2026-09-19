{
  den.aspects.graphics.nixos = {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };

    services.xserver.videoDrivers = ["amdgpu"];
  };
}
