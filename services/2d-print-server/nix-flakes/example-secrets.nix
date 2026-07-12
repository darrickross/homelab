# example-secrets.nix
#
# Template for secrets.nix.  Copy this file:
#   cp example-secrets.nix secrets.nix
# Then fill in your real values.
#
# secrets.nix is listed in .gitignore and must NOT be committed to git.

{
  # Hostname for this machine.
  system-hostname = "print-server";

  # Network interface name.
  # Run `ip a` on the device to confirm the correct name.
  #   rpi4     → typically "end0" (or "eth0" on older kernels)
  #   vm-amd64 → typically "eth0" or "ens3"
  system-network-interface = "end0";

  # Static IPv4 configuration.
  system-ipv4-address  = "192.168.0.50";   # Replace with your desired static IP
  system-ipv4-prefix   = 24;               # CIDR prefix length (24 = /24 = 255.255.255.0)
  system-ipv4-gateway  = "192.168.0.1";    # Replace with your router/gateway IP
  system-ipv4-dns-list = [
    "192.168.0.1"   # Primary DNS (often the router)
    # "1.1.1.1"     # Optional: upstream public DNS
  ];

  # SSH port (default 22).
  system-ssh-port = 22;

  # Admin username that will be created on the system.
  system-admin-user = "admin";

  # SSH public keys authorised to log in as the admin user.
  system-ssh-authorized-keys = [
    # "sk-ssh-ed25519@openssh.com AAAA... YourKey comment"
  ];
}
