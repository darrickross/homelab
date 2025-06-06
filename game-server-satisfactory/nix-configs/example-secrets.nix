{
  # System Networking config
  system-hostname = "satisfactory-prod";
  system-ipv4-address = "192.168.0.41"; # Replace with your static IP address
  system-ipv4-prefix = 24;
  system-ipv4-gateway = "192.168.0.1"; # Replace with your gateway IP address
  system-ipv4-dns-list = [ "192.168.0.4" "192.168.0.1" ];
  system-ipv4-use-mtu = true;
  system-ipv4-mtu-value = 9000;

  system-ssh-port = "22";

  # Satisfactory Ports
  server-game-port = "7777";
}
