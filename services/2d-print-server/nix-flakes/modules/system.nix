# modules/system.nix
#
# Base system configuration: SSH, timezone, locale, and admin user.
# Secrets (hostname, IP, SSH keys, etc.) are loaded from secrets.nix.
# Copy example-secrets.nix → secrets.nix and fill in your values.

{
  config,
  pkgs,
  lib,
  ...
}:

let
  # secrets.nix is NOT committed to git – see example-secrets.nix for the
  # expected shape and .gitignore for the exclusion rule.
  secrets = import ../secrets.nix;
in
{
  # ---------------------------------------------------------------------------
  # SSH
  # ---------------------------------------------------------------------------
  services.openssh = {
    enable = true;
    ports = [ secrets.system-ssh-port ];
    settings = {
      PasswordAuthentication = false; # key-based auth only
      PermitRootLogin = "no";
    };
  };

  # ---------------------------------------------------------------------------
  # Locale & timezone
  # ---------------------------------------------------------------------------
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";

  # ---------------------------------------------------------------------------
  # Admin user
  # ---------------------------------------------------------------------------
  users.users.${secrets.system-admin-user} = {
    isNormalUser = true;
    # lp      – access to print queues
    # scanner – access to SANE scanner devices
    # wheel   – sudo
    extraGroups = [
      "lp"
      "scanner"
      "wheel"
    ];
    openssh.authorizedKeys.keys = secrets.system-ssh-authorized-keys;
  };

  # Required when gutenprintBin or future official Brother drivers are included.
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "24.11";
}
