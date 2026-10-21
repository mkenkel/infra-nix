{den, ...}: {
  den.aspects.davinci-resolve = {
    includes = [
      (den.batteries.unfree [
        "davinci-resolve"
      ])
    ];
    nixos = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [
        davinci-resolve
      ];

      # Resolve needs OpenCL for GPU compute; ROCm's ICD covers amdgpu.
      hardware.graphics.extraPackages = [pkgs.rocmPackages.clr.icd];
    };
  };
}
