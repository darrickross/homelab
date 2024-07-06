{
    # System Networking config
    system-hostname         = "icarus-prod";
    system-ipv4-address     = "192.168.0.41";       # Replace with your static IP address
    system-ipv4-prefix      = 24;                   # Replace with your subnet prefix (24 is /24 in CIDR notation)
    system-ipv4-gateway     = "192.168.0.1";        # Replace with your gateway IP address (your router's IP address)
    system-ipv4-dns-list    = [
        "192.168.0.4"                               # Your local DNS server (usually your router)
        "192.168.0.1"                               # Your local DNS server secondary
        # "8.8.8.8"                                 # Uncomment to use Google DNS
    ];
    system-ssh-port         = "22";                 # Use this to override the default SSH port

    # Icarus Ports
    server-game-port-udp    = "17777";
    server-query-port-udp   = "27015";
}
