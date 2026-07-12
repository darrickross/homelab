# modules/printing.nix
#
# CUPS print server for a Brother HL-L3280CDW connected via USB.
#
# How USB printing works:
#   The printer is physically connected to the RPi4 by USB.  Linux exposes it
#   as /dev/usb/lp0 via the usblp kernel module.  CUPS auto-detects it through
#   its usb backend and presents it to network clients over IPP on port 631.
#   Clients never need to know the printer is USB; they just print to the
#   server's IP address.
#
# ── Driver notes ──────────────────────────────────────────────────────────────
#
#   rpi4  (aarch64-linux)  ← currently implemented
#     Brother's official CUPS wrapper binaries are x86/x86_64-only blobs and
#     will NOT run on ARM.  We use open-source alternatives:
#
#       • brlaser     – open-source raster driver covering many Brother mono
#                       lasers.  Select the "Brother HL-L3270DW" PPD as a close
#                       match if HL-L3280CDW is not listed in the CUPS web UI.
#
#       • gutenprint  – broad vendor coverage including some Brother color
#                       laser models via generic PCL/raster.
#
#     Adding the printer:
#       Open http://<server-ip>:631 → Administration → Add Printer.
#       The HL-L3280CDW will appear under "Local Printers" as a USB device.
#       Select a brlaser or gutenprint PPD from the driver list.
#
#   vm-amd64 (x86_64-linux) ← future
#     The official Brother CUPS wrapper can be used on amd64:
#
#       services.printing.drivers = [ pkgs.brother-hll3270cdw ];
#                                              ↑ closest package in nixpkgs;
#                                                update once HL-L3280CDW lands.
#
#     The printer would still appear as a local USB device in CUPS.
#
# ──────────────────────────────────────────────────────────────────────────────

{ config, pkgs, systemType, ... }:

{
  # ---------------------------------------------------------------------------
  # usblp – kernel module that exposes USB printers as /dev/usb/lp*
  # CUPS's usb backend requires this to communicate with the printer.
  # ---------------------------------------------------------------------------
  boot.kernelModules = [ "usblp" ];

  # ---------------------------------------------------------------------------
  # udev rule – give the CUPS daemon (group lp) read/write access to the
  # Brother USB device without running as root.
  # Brother USB vendor ID: 0x04f9
  # ---------------------------------------------------------------------------
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="04f9", MODE="0664", GROUP="lp"
  '';

  # ---------------------------------------------------------------------------
  # CUPS daemon
  # ---------------------------------------------------------------------------
  services.printing = {
    enable = true;

    # Accept print jobs from network clients, not just localhost.
    listenAddresses = [ "*:631" ];
    allowFrom       = [ "all" ]; # Restrict to your subnet in production,
                                  # e.g. [ "192.168.0.0/24" ]
    browsing      = true;
    defaultShared = true;

    drivers = with pkgs; [
      # Open-source Brother raster driver – works on aarch64 and amd64.
      brlaser

      # Gutenprint: broad vendor coverage including some Brother color lasers.
      gutenprint
      gutenprintBin

      # Future vm-amd64: replace / augment with the official Brother wrapper:
      # brother-hll3270cdw   # closest nixpkgs match; update to hll3280cdw once available
    ];
  };

  # ---------------------------------------------------------------------------
  # Avahi – advertise the shared print queue via mDNS (AirPrint / IPP)
  # so clients can discover it automatically without manual configuration.
  # ---------------------------------------------------------------------------
  services.avahi = {
    enable   = true;
    nssmdns4 = true;
    publish = {
      enable       = true;
      userServices = true;
    };
  };

  # gutenprintBin contains precompiled binaries; allow unfree packages.
  nixpkgs.config.allowUnfree = true;
}
