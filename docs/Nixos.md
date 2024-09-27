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

While technically `vim` is commented in the list, I wanted to show adding to the list.
