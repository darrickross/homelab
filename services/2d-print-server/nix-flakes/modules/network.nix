# modules/network.nix
#
# Static IP, hostname, and firewall for the print/scan server.
#
# Ports opened:
#   22   TCP – SSH
#   631  TCP – CUPS / IPP (printing)
#   5353 UDP – mDNS (Avahi / AirPrint discovery)
#   6566 TCP – saned (SANE network scanning)
#
# Network interface name notes:
#   rpi4     → typically "end0" (predictable naming) or "eth0" on older kernels.
#              Check with `ip a` on the device and update system-network-interface
#              in secrets.nix accordingly.
#
#   vm-amd64 → typically "eth0" or "ens3" depending on the hypervisor.
#              Same approach: check with `ip a` and update the secrets value.

{ config, pkgs, lib, ... }:

let
  secrets = import ../secrets.nix;
in
{
  networking.hostName = secrets.system-hostname;

  # Disable NetworkManager; we manage the interface statically below.
  networking.networkmanager.enable = false;

  # Static IP on the primary interface.
  networking.interfaces.${secrets.system-network-interface} = {
    useDHCP = false;
    ipv4.addresses = [{
      address      = secrets.system-ipv4-address;
      prefixLength = secrets.system-ipv4-prefix;
    }];
  };

  networking.defaultGateway = secrets.system-ipv4-gateway;
  networking.nameservers    = secrets.system-ipv4-dns-list;

  # ---------------------------------------------------------------------------
  # Firewall
  # ---------------------------------------------------------------------------
  networking.firewall = {
    enable = true;

    allowedTCPPorts = [
      secrets.system-ssh-port # SSH
      631                     # CUPS / IPP – print job submission and CUPS web UI
      6566                    # saned – SANE network scanning
    ];

    allowedUDPPorts = [
      5353 # mDNS – Avahi / AirPrint / IPP Everywhere discovery
    ];
  };
}
