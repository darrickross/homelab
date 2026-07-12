# modules/scanning.nix
#
# SANE scanning for a Brother HL-L3280CDW connected via USB.
#
# How USB scanning works:
#   SANE talks directly to the scanner over USB using a backend driver.
#   saned then exposes that scanner to other hosts on the network over TCP
#   port 6566, so a desktop client (e.g. simple-scan) can scan remotely by
#   pointing at this server's IP.
#
# ── Driver notes (aarch64 USB caveat) ─────────────────────────────────────────
#
#   rpi4  (aarch64-linux)  ← currently implemented
#     Brother's official USB scanner backends (brscan4, brscan5) are
#     x86/x86_64-only binary blobs – they will NOT run on aarch64.
#
#     Open-source fallback: the "brother2" backend shipped inside sane-backends
#     covers a range of Brother scanners and is pure C (aarch64-compatible).
#     Whether it supports the HL-L3280CDW depends on the SANE version in
#     nixpkgs.  Test with:
#
#       scanimage -L          # list detected devices
#       scanimage > test.pnm  # attempt a scan
#
#     If brother2 does not detect the scanner, the two remaining options are:
#       a) Switch to a vm-amd64 host (see below) where brscan5 works.
#       b) Configure the printer for eSCL over its wired/wireless network
#          interface and use sane-airscan on any architecture.  This requires
#          the printer to have a network connection in addition to USB.
#          Enable eSCL on the printer:
#            Printer web UI → Scan → Web Services  (exact path varies by FW)
#          Then add sane-airscan to extraBackends alongside the brother2 entry.
#
#   vm-amd64 (x86_64-linux) ← future
#     The official Brother USB backend works on amd64:
#
#       hardware.sane.extraBackends = [ pkgs.brscan5 ];
#
#     Register the USB-attached device so SANE can find it by model:
#       hardware.sane.brscan5.enable = true;
#       hardware.sane.brscan5.netDevices."hl-l3280cdw" = {
#         model = "HL-L3280CDW";
#         nodename = "libusb:XXX:YYY";  # from `scanimage -L` output; or omit
#       };                               # and let brscan5 auto-detect via USB
#
#     sane-airscan can also be kept alongside brscan5 as a fallback:
#       hardware.sane.extraBackends = [ pkgs.brscan5 pkgs.sane-airscan ];
#
# ──────────────────────────────────────────────────────────────────────────────

{
  config,
  pkgs,
  systemType,
  ...
}:

{
  # ---------------------------------------------------------------------------
  # udev rule – give the SANE daemon (group scanner) access to the Brother USB
  # device.  Same vendor ID used in printing.nix for the CUPS rule.
  # Brother USB vendor ID: 0x04f9
  # ---------------------------------------------------------------------------
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="04f9", MODE="0664", GROUP="scanner"
  '';

  # ---------------------------------------------------------------------------
  # SANE scanning subsystem
  # ---------------------------------------------------------------------------
  hardware.sane = {
    enable = true;

    extraBackends = [
      # sane-backends already includes the "brother2" USB backend.
      # Listing it here explicitly ensures it is present; adjust if nixpkgs
      # splits it into a separate derivation in the future.
      pkgs.sane-backends

      # Future rpi4 network-fallback: if brother2 does not work, enable eSCL
      # on the printer's network interface and uncomment:
      # pkgs.sane-airscan

      # Future vm-amd64: official Brother USB backend (x86_64 only):
      # pkgs.brscan5
    ];
  };

  # ---------------------------------------------------------------------------
  # saned – expose the USB scanner to other hosts on the network
  # Clients point simple-scan / xsane at this server's IP on port 6566.
  # ---------------------------------------------------------------------------
  services.saned = {
    enable = true;
    # Restrict to your LAN subnet.
    extraConfig = ''
      # Allow hosts on the local network to use the scanner.
      192.168.0.0/24
    '';
  };

  # scanimage is the standard SANE CLI tool; useful for testing on the server.
  # Run `scanimage -L` after boot to verify the printer is detected.
  environment.systemPackages = [ pkgs.sane-backends ];
}
