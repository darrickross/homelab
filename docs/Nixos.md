# Useful notes about NixOS

This is a collection of notes on NixOS and how to work with it.

## Relative Folder Structure

- [*root directory*](../README.md)
  - [/docs](./README.md)
    - [NixOS.md](Nixos.md) <------------ ***YOU ARE HERE***

## Table of Contents

- [Relative Folder Structure](#relative-folder-structure)
- [Table of Contents](#table-of-contents)
- [Useful Notes](#useful-notes)
  - [NixOS Text Editors](#nixos-text-editors)
  - [Installing Packages on NixOS](#installing-packages-on-nixos)
  - [Set up SSH on NixOS](#set-up-ssh-on-nixos)

## Useful Notes

### NixOS Text Editors

Most text editing packages do not come installed by default in NixOS.
By default (in 24.05) `nano` is installed but `vi`/`vim` is not.

```txt
$ nano --version
 GNU nano, version 8.0
 (C) 2024 the Free Software Foundation and various contributors
 Compiled options: --enable-utf8

$ vi --version
vi: command not found

$ vim --version
vim: command not found
```

As you can see, `nano` is the only editor in this list which is installed by default on NixOS.

### Installing Packages on NixOS

If you want to install another package like `vim` you must add it to the list of installed packages.

```bash
sudo nano /etc/nixos/configuration.nix
```

Find the main section

```nix
# Omitted beginning of /etc/nixos/configuration.nix
{
  # Omitted parts here...

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  # Omitted parts here...
}
# Omitted end /etc/nixos/configuration.nix
```

Add the package you want to packages list.

For example I might add `vim`:

```nix
# Omitted beginning of /etc/nixos/configuration.nix
{
  # Omitted parts here...

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    vim # <---------------------------------------- New package
  ];

  # Omitted parts here...
}
# Omitted end /etc/nixos/configuration.nix
```

Do not need commas for this list. NixOS will fail to build if you do.

> [!NOTE]
> While technically, I could have uncommented `vim` in the list, I wanted to show adding to the list.

After adding packages to the list you will need to rebuild NixOS.

```bash
sudo nixos-rebuild switch
```

Example output it might show:

```text
$ sudo nixos-rebuild switch
building Nix...
building the system configuration...
these 11 derivations will be built:
  /nix/store/32c5qamfykn25n86naqkzl4lrpifbgg8-system-path.drv
  /nix/store/fn9jac6lcmhhpn0vm1ih4fpayy6cjsxn-X-Restart-Triggers-polkit.drv
  /nix/store/1m577xwk5wak6l7p2nrj7nrha444ah52-unit-polkit.service.drv
  /nix/store/gcrs6b5kxj318knwhkw6ngsl5ba01bbr-dbus-1.drv
  /nix/store/bj7hqfl46v11z2gwxw15j290yk901zfl-X-Restart-Triggers-dbus.drv
  /nix/store/cvjihkc68s7c18cbnq3xax589x6l9hyv-unit-dbus.service.drv
  /nix/store/b3yqk71pgcgnigny6yg6kkk6mh787zqk-system-units.drv
  /nix/store/z7451mmmdmrlcv7glnpd7v5vm6b4gcs1-unit-dbus.service.drv
  /nix/store/nj4n4hhjl4x695aq37ci2ravvn1vrzsj-user-units.drv
  /nix/store/brkwklqbm0ggq4672rlc3gfk665m4548-etc.drv
  /nix/store/1a3wy672yw9wvccxspaddfhvg72plcin-nixos-system-nixos-24.05.5266.babc25a577c3.drv
building '/nix/store/32c5qamfykn25n86naqkzl4lrpifbgg8-system-path.drv'...
created 7027 symlinks in user environment
building '/nix/store/fn9jac6lcmhhpn0vm1ih4fpayy6cjsxn-X-Restart-Triggers-polkit.drv'...
building '/nix/store/gcrs6b5kxj318knwhkw6ngsl5ba01bbr-dbus-1.drv'...
building '/nix/store/1m577xwk5wak6l7p2nrj7nrha444ah52-unit-polkit.service.drv'...
building '/nix/store/bj7hqfl46v11z2gwxw15j290yk901zfl-X-Restart-Triggers-dbus.drv'...
building '/nix/store/cvjihkc68s7c18cbnq3xax589x6l9hyv-unit-dbus.service.drv'...
building '/nix/store/z7451mmmdmrlcv7glnpd7v5vm6b4gcs1-unit-dbus.service.drv'...
building '/nix/store/b3yqk71pgcgnigny6yg6kkk6mh787zqk-system-units.drv'...
building '/nix/store/nj4n4hhjl4x695aq37ci2ravvn1vrzsj-user-units.drv'...
building '/nix/store/brkwklqbm0ggq4672rlc3gfk665m4548-etc.drv'...
building '/nix/store/1a3wy672yw9wvccxspaddfhvg72plcin-nixos-system-nixos-24.05.5266.babc25a577c3.drv'...
updating GRUB 2 menu...
Warning: os-prober will be executed to detect other bootable partitions.
Its output will be used to detect bootable binaries on them and create new boot entries.
lsblk: /dev/mapper/no*[0-9]: not a block device
lsblk: /dev/mapper/raid*[0-9]: not a block device
lsblk: /dev/mapper/disks*[0-9]: not a block device
activating the configuration...
setting up /etc...
reloading user units for architect...
restarting sysinit-reactivation.target
reloading the following units: dbus.service

$
```

### Set up SSH on NixOS

1. Log in with an admin user
2. Modify the `/etc/nixos/configuration.nix` to allow SSH
    1. `sudo nano /etc/nixos/configuration.nix`
    2. Lines to change

        ```diff
          # List services that you want to enable:

          # Enable the OpenSSH daemon
        - # services.openssh.enable = true
        + services.openssh.enable = true;

          # Open ports in the firewall
        - # networking.firewall.allowedTCPPorts = [ ... ]
        + networking.firewall.enable = true;
        + networking.firewall.allowedTCPPorts = [ 22 ];
          # networking.firewall.allowedUDPPorts = [ ... ]
          # Or disable the firewall altogether
          # networking.firewall.enable = false
        ```

    3. End result

        ```nix
        {
          # Omitted HERE ...

          # List services that you want to enable:

          # Enable the OpenSSH daemon.
          services.openssh.enable = true;

          # Open ports in the firewall.
          networking.firewall.enable = true;
          networking.firewall.allowedTCPPorts = [ 22 ];
          # networking.firewall.allowedUDPPorts = [ ... ];
          # Or disable the firewall altogether.
          # networking.firewall.enable = false;

          # Omitted HERE ...
        }
        ```

3. Reload the Nix Config

    ```bash
    sudo nixos-rebuild switch
    ```

You can now ssh into the system using the system's IP address, or hostname.

Find the IP Address using

```bash
ip a
```
