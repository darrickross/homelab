# system-configs.nix
{ config, pkgs, lib, ... }:

let
  # Secret Variables
  # Import secrets as a variable from another file
  # Example ./secrets.nix content:
  # {
  #     system-hostname         = "satisfactory-prod";
  #     system-ipv4-address     = "192.168.0.41";       # Replace with your static IP address
  #     system-ipv4-gateway     = "192.168.0.1";        # Replace with your gateway IP address
  #     system-ipv4-dns-list    = [
  #         "192.168.0.4"
  #         "192.168.0.1"
  #     ];
  #     system-ssh-port         = "22";
  # }
  secrets = import ./secrets.nix;
in {
  # Enable and Allow SSH
  services.openssh.enable = true;
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ (lib.toInt secrets.system-ssh-port) ];

  # Configure System with Static IP
  networking.interfaces.eth0.ipv4.addresses = [{
    address = secrets.system-ipv4-address;
    prefixLength = secrets.system-ipv4-prefix;
  }];
  # This uses eth0, you will want to check which device you are using on your system
  # Check using 'ip a' and looking for the name of the device you are changing the settings of

  # Remaining network settings
  networking.defaultGateway = secrets.system-ipv4-gateway;
  networking.nameservers = secrets.system-ipv4-dns-list;
  networking.hostName = secrets.system-hostname;
  # Make sure to comment out the same config from the /etc/nixos/configuration.nix file

  # Enable QEMU Guest Agent
  # Used by Proxmox
  services.qemuGuest.enable = true;
}
