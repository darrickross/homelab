{
  description = "2D Print Server for Brother HL-L3280CDW";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";

    # nixos-hardware provides ready-made hardware configs for common devices.
    # The raspberry-pi-4 module handles DTB overlays, firmware, and kernel params.
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    # Future vm-amd64: no additional inputs are needed.  The standard nixpkgs
    # QEMU/Proxmox guest modules are included in nixpkgs itself.
  };

  outputs = { self, nixpkgs, nixos-hardware }:
    let

      # -----------------------------------------------------------------------
      # systemType → NixOS system architecture
      #
      # To add a new system type:
      #   1. Add a new entry to archFor.
      #   2. Add a matching entry to platformModulesFor below.
      #   3. Add a new attribute to nixosConfigurations at the bottom.
      # -----------------------------------------------------------------------
      archFor = {
        rpi4     = "aarch64-linux";

        # Future: AMD64 VM (e.g. Proxmox / QEMU)
        # vm-amd64 = "x86_64-linux";
      };

      # -----------------------------------------------------------------------
      # systemType → platform-specific NixOS modules
      # -----------------------------------------------------------------------
      platformModulesFor = {
        rpi4 = [
          # Full Raspberry Pi 4 hardware support: firmware, overlays, U-Boot.
          nixos-hardware.nixosModules.raspberry-pi-4
        ];

        # Future vm-amd64:
        # vm-amd64 = [
        #   # Enables the QEMU guest agent (useful when running under Proxmox).
        #   "${nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
        # ];
      };

      # -----------------------------------------------------------------------
      # mkPrintServer – factory that builds a NixOS system for a given
      # systemType string.  Composes the platform-specific modules with the
      # shared service modules.
      # -----------------------------------------------------------------------
      mkPrintServer = systemType:
        nixpkgs.lib.nixosSystem {
          system      = archFor.${systemType};
          # systemType is forwarded as a specialArg so individual modules can
          # branch on it (e.g. to choose platform-appropriate drivers).
          specialArgs = { inherit systemType; };
          modules     = platformModulesFor.${systemType} ++ [
            ./modules/system.nix
            ./modules/network.nix
            ./modules/printing.nix
            ./modules/scanning.nix
          ];
        };

    in
    {
      # -----------------------------------------------------------------------
      # Build commands
      #
      #   RPi4 SD card image:
      #     nix build .#nixosConfigurations.rpi4.config.system.build.sdImage
      #
      #   Deploy with nixos-rebuild (when SSH'd into the target):
      #     nixos-rebuild switch --flake .#rpi4
      #
      # Future vm-amd64:
      #   nix build .#nixosConfigurations.vm-amd64.config.system.build.vm
      #   nixos-rebuild switch --flake .#vm-amd64
      # -----------------------------------------------------------------------
      nixosConfigurations = {
        rpi4 = mkPrintServer "rpi4";

        # vm-amd64 = mkPrintServer "vm-amd64";
      };
    };
}
