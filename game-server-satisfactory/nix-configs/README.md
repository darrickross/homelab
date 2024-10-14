# Nixos Config

This directory represents an example of how to set up a Satisfactory server on NixOS. This is much better than my initial [simple-ubuntu-configs/](../simple-ubuntu-configs/README.md) deployment of satisfactory. NixOS represents an Infrastructure as Code (IaC), or really Configuration as Code (CaC??). Which given the host a massive ability to control what is deployed, and manage that in git (or other source control) instead of manually changing somethings on the server.

To back up a bit and really step onto a soap box for a paragraph. [Infrastructure as Code](https://aws.amazon.com/what-is/iac/) is a time savings way to manage resources. If its in code, or really in git (or other source control), that can be tracked. Rolled back. Branched. Or any other 'action' expected of modern software design. With Infrastructure as Code there is no question of what was deployed. The same thing can be deployed to multiple places with the exact same structures and results. The security savings are also massive. Static code analysis tools can be let loose on infrastructure if that infrastructure is in code. Meaning I can get warnings if the combination of settings I am about to do is either missing a critical security piece, or is plain inefficient.

Now realistically, what I have going on here is not a massive cost savings by deploying with Infrastructure as Code. But what it does do is build the foundations for my later ability to [spin 100% of my non-core infrastructure using automation like GitHub actions, or other CI/CD runner](https://www.youtube.com/watch?v=tIWDpG7sNTU). Having this automation trigger on detection of a change to my infrastructure. Meaning I can spin up, spin down, and roll back, *automagically*.

This rant may move somewhere else, maybe a dedicated rants folder at the root.

## 0 - Relative Folder Structure

- [*root directory*](../../README.md)
  - [/game-server-satisfactory](../README.md)
    - [nix-configs/](./README.md) <------------ ***YOU ARE HERE***
      - `example-secrets.nix`
        - Set of configuration settings which are best left secret.
        - [`example-secrets.nix` Explained](./explaining-nix-config.md#2---example-secretsnix)
      - `satisfactory.nix`
        - Core Nix config which sets up Satisfactory.
        - [`satisfactory.nix` Explained](./explaining-nix-config.md#3---satisfactorynix)
      - `system-configs.nix`
        - Core system configuration settings.
        - [`system-configs.nix` Explained](./explaining-nix-config.md#4---system-configsnix)
    - [simple-ubuntu-configs/](../simple-ubuntu-configs/README.md)

## 1 - Table of Contents

- [0 - Relative Folder Structure](#0---relative-folder-structure)
- [1 - Table of Contents](#1---table-of-contents)
- [2 - Attribution](#2---attribution)
- [3 - How to use these configs](#3---how-to-use-these-configs)
- [4 - Where to access the server](#4---where-to-access-the-server)
- [5 - Read next?](#5---read-next)

## 2 - Attribution

Initially I used the example [Valheim Server on NixOS v2](https://kevincox.ca/2022/12/09/valheim-server-nixos-v2/). But I have since branched from the initial guide as I slowly start to better understand NixOS.

## 3 - How to use these configs

> [!TIP]
> As a first step if you have just installed NixOS you will need to obtain a connection to the server. One method of this is to enable SSH. If you need help doing this use my guide on setting up SSH on nixos for the first time.
> [REPO_ROOT/docs/nixos.md - 2.c - Set up SSH on NixOS](../../docs/Nixos.md#2c---set-up-ssh-on-nixos)

After you spin up NixOS on the system you will be hosting Satisfactory on. You will want to open the system and transfer the 3 files to it

1. `satisfactory.nix`
2. `secrets.nix`
    - This file is not initially provided as it contains values which should be secret and not committed to version control.
    - Copy the `example-secrets.nix` and name it `secrets.nix` updating any values as needed.
3. `system-configs.nix`

I `curl` them down from my repo, but you might need to use `scp`.

```bash
cd /etc/nixos/

sudo curl -L -O https://github.com/darrickross/infrastructure-services/raw/refs/heads/main/game-server-satisfactory/nix-configs/example-secrets.nix
sudo curl -L -O https://github.com/darrickross/infrastructure-services/raw/refs/heads/main/game-server-satisfactory/nix-configs/satisfactory.nix
sudo curl -L -O https://github.com/darrickross/infrastructure-services/raw/refs/heads/main/game-server-satisfactory/nix-configs/system-configs.nix

sudo mv example-secrets.nix secrets.nix

# Change contents of secrets.nix to match your environment's ip
sudo nano secrets.nix
```

After transferring these files to the NixOS system we will move them to the root config directory `/etc/nixos/`.

> [!IMPORTANT]
> `/etc/nixos/` is a root user controlled directory, aka `sudo` or the less secure way, `su` to root.

&

> [!WARNING]
> Dumping these configs in the root nixos configs directory `/etc/nixos/` is not exactly the best solution. A better solution might be to create a folder in the root configs directory (aka `/etc/nixos/satisfactory/`) which contains all satisfactory configs for example. This is however an improvement I will be looking into when I set up the terraform deployment for this server to truly make this an automatic deployment from start to finish.

Now that the 3 files exist in the root config directory `/etc/nixos/` like so:

```text
[manager@nixos:~]$ ls -al /etc/nixos/
total 32
drwxr-xr-x  2 root root 4096 Jan 21 21:40 .
drwxr-xr-x 23 root root 4096 Mar 20 20:08 ..
-rw-r--r--  1 root root 3179 Jan 21 21:58 configuration.nix             <--- Created by NixOS
-rw-r--r--  1 root root 1185 Jan 21 20:55 hardware-configuration.nix    <--- Created by NixOS
-rw-r--r--  1 root root 7050 Jan 21 21:40 satisfactory.nix              <--- File we created
-rw-r--r--  1 root root  470 Jan 21 21:57 secrets.nix                   <--- File we created
-rw-r--r--  1 root root 1667 Jan 21 21:58 system-configs.nix            <--- File we created

[manager@nixos:~]$
```

Next we will want to modify `configuration.nix` to include the new `satisfactory.nix` and `system-configs.nix` configs added.

You can do this with you favorite text editor.

> [!IMPORTANT]
> Most text editing packages do not come installed by default in NixOS.
> By default (in 24.05) `nano` is installed but `vi`/`vim` is not.
>
> If you need another text editor follow the guide in [REPO_ROOT/docs/nixos.md - 2.b - Installing Packages on NixOS](../../docs/Nixos.md#2b---installing-packages-on-nixos)

```bash
sudo nano /etc/nixos/configuration.nix
```

At the very top of the `configuration.nix` config we will see:

```nix
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

    # ... OMITTED
}
```

We will want to update the imports to include both of the main nix configs, `satisfactory.nix` and `system-configs.nix`.

Make the following changes:

```diff
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
+
+     # Basic System Configs
+     ./system-configs.nix
+
+     # Satisfactory dedicated game server
+     ./satisfactory.nix
    ];

    # ... OMITTED
}
```

The final result might look like so:

```nix
# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix

      # Basic System Configs
      ./system-configs.nix

      # Satisfactory dedicated game server
      ./satisfactory.nix
    ];

    # ... OMITTED
}
```

> [!NOTE]
> This assumes the new configs were placed in the root nixos config directory, `/etc/nixos/`. If your configs are in a different location ensure the path (*absolute, or relative from `/etc/nixos/` folder*) is included.

Since we have specified a different hostname in `secrets.nix` used in `system-configs.nix` then comment out the hostname defined in the original `/etc/nixos/configuration.nix`

```bash
sudo sed -i '/^[[:space:]]*networking\.hostName/s/^/#/' /etc/nixos/configuration.nix
```

Finally we will need to update the system by running a system rebuild

```bash
sudo nixos-rebuild switch
```

Example output

```text
$ sudo nixos-rebuild switch
building Nix...
building the system configuration...
updating GRUB 2 menu...
Warning: os-prober will be executed to detect other bootable partitions.
Its output will be used to detect bootable binaries on them and create new boot entries.
lsblk: /dev/mapper/no*[0-9]: not a block device
lsblk: /dev/mapper/raid*[0-9]: not a block device
lsblk: /dev/mapper/disks*[0-9]: not a block device
stopping the following units: logrotate-checkconf.service, network-setup.service, systemd-sysctl.service, systemd-tmpfiles-resetup.service
activating the configuration...
reviving group 'satisfactory' with GID 994
reviving user 'satisfactory' with UID 995
setting up /etc...
reloading user units for architect...
restarting sysinit-reactivation.target
reloading the following units: dbus.service, firewall.service
starting the following units: logrotate-checkconf.service, network-setup.service, systemd-sysctl.service, systemd-tmpfiles-resetup.service
the following new units were started: satisfactory.service

$
```

This will rebuild the system based on the current state of the `/etc/nixos/configuration.nix` config. This will also include any additional files included using the `imports` block.

Assuming everything built successfully you can see logs located in log directory for the satisfactory server where the config specified in `satisfactory.nix` under the variable `log-folder`.

You can also check the systemctl status of the service using:

```bash
sudo systemctl status satisfactory
```

- TODO add Output from fresh build

## 4 - Where to access the server

## 5 - Read next?

If you want an explanation of each NixOS config read the [Explaining-Nix-Config.md](Explaining-Nix-Config.md)
