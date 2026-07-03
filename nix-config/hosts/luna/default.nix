{
  config,
  pkgs,
  lib,
  hostMeta ? {
    isGui = true;
    autoLogin = false;
  },
  primaryUser ? "itsjustmech",
  ...
}:

{
  imports = [
    # System's Hardware Info
    ./hardware-configuration.nix

    # GUI/desktop stack split into its own module
    ../../modules/default-gui.nix

    # Pull in the default locale and time settings
    ../../modules/default-locale-time.nix

    # Pull in this systems networking defaults
    ./networking.nix
  ];

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${primaryUser} = {
    isNormalUser = true;
    description = primaryUser;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [ kdePackages.kate ];
  };

  # Depending on if the metadata sets it, allow autoLogin
  services.displayManager.autoLogin = lib.mkIf hostMeta.autoLogin {
    enable = true;
    user = primaryUser;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH server.
  services.openssh.enable = true;
}
