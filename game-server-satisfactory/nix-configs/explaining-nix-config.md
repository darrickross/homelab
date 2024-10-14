
# Explaining Nix Config

Here I explain each of the Nix configs in this module.

## 0 - Relative Folder Structure

- [*root directory*](../../README.md)
  - [/game-server-satisfactory](../README.md)
    - [nix-configs/](./README.md)
      - [Explaining-Nix-Config.md](Explaining-Nix-Config.md) <------------ ***YOU ARE HERE***
      - [README.md](README.md)

## 1 - Table of Contents

- [0 - Relative Folder Structure](#0---relative-folder-structure)
- [1 - Table of Contents](#1---table-of-contents)
- [2 - `example-secrets.nix`](#2---example-secretsnix)
- [3 - `satisfactory.nix`](#3---satisfactorynix)
  - [3.a - Variables](#3a---variables)
  - [3.b - Service Account](#3b---service-account)
  - [3.c - Systemd Service for Satisfactory](#3c---systemd-service-for-satisfactory)
  - [3.d - Firewall](#3d---firewall)
  - [3.e - Logging](#3e---logging)
- [4 - `system-configs.nix`](#4---system-configsnix)

## 2 - `example-secrets.nix`

> [!IMPORTANT]
> This is an example file and is not intended to be used.
>
> The file `secrets.nix` will contain sensitive values which are expected to be left out of source control. Therefore the file is not included in source control, nor included in this guide.
>
> Instead an example file `example-secrets.nix` is provided which contains example sensitive values.

The `secrets.nix` and example version `example-secrets.nix` is used to configure important variables, which are potentially sensitive, aka the name *secrets*. This file is then imported into other nix configs. Allowing those nix config files to stay static, with the `secrets.nix` changing based on the systems networking configs.

> [!CAUTION]
> Ensure a file `secrets.nix` is created and includes the below config which is updated to match your network settings.

```nix
{
    # System Networking config
    system-hostname         = "satisfactory-prod";
    system-ipv4-address     = "192.168.0.41";       # Replace with your static IP address
    system-ipv4-prefix      = 24;
    system-ipv4-gateway     = "192.168.0.1";        # Replace with your gateway IP address
    system-ipv4-dns-list    = [
        "192.168.0.4"
        "192.168.0.1"
    ];
    system-ssh-port         = "22";

    # Satisfactory Ports
    server-game-port-udp    = "7777";
    server-beacon-port-udp  = "15000";
    server-query-port-udp   = "15777";
}
```

> [!NOTE]
> I have not looked into IPv6 as of writing. IPv6 is also still being implemented in satisfactory.

## 3 - `satisfactory.nix`

### 3.a - Variables

First we define all the variables which will be used.

```nix
{config, pkgs, lib, ...}:

let
    # The Steam Game "Dedicated Server" App ID
    # Set to {id}-{branch}-{password} for betas.
    steam-game-server-app-id    = "1690800";  # Satisfactory Dedicated Server App ID
    steam-game-beta-id          = "";
    steam-game-beta-password    = "";

    # Game Server Install Folder
    server-install-directory    = "/var/lib/satisfactory";

    # Secret Variables
    # Import secrets as a variable from another file
    # Example ./secrets.nix content:
    # {
    #     server-game-port-udp    = "7777";
    #     server-beacon-port-udp  = "15000";
    #     server-query-port-udp   = "15777";
    # }
    secrets                     = import ./secrets.nix;

    # Game Server Network Port Settings
    # https://satisfactory.fandom.com/wiki/Dedicated_servers#Port_forwarding_and_firewall_settings

    # Logging Variables
    log-folder                  = "/var/log/satisfactory";
    log-file-stdout             = "stdout.log";
    log-file-stderr             = "stderr.log";
in {
    # ...
}
```

### 3.b - Service Account

Next we want to create a service account who will operate this server. This ensures your not giving root permissions to the server, which might end up being a vulnerability.

```nix
let
   #...
in
{
    users.users.satisfactory = {
        isSystemUser = true;
        # Satisfactory puts save data in the home directory.
        home         = "/home/satisfactory";
        createHome   = true;
        homeMode     = "750";
        group        = "satisfactory";
    };

    users.groups.satisfactory = {};

    #...
}
```

### 3.c - Systemd Service for Satisfactory

Next we define the core Service, ill break out and explain both the `ExecStartPre` and `ExecStart` blocks below. But the rest are Systemd Service options.

```nix
let
    # ...
in
{
    # ...

    # Service to run the game
    systemd.services.satisfactory = {

        # https://satisfactory.fandom.com/wiki/Dedicated_servers/Running_as_a_Service
        wantedBy = [
            "multi-user.target"
        ];

        wants = [
            "network-online.target"
        ];
        after = [
            "network.target"
            "network-online.target"
            "nss-lookup.target"
            "syslog.target"
        ];

        serviceConfig = {
            # Download the game
            # Then fix those binaries using patchelf
            ExecStartPre = "${pkgs.resholve.writeScript "steam" {
                interpreter = "${pkgs.zsh}/bin/zsh";
                inputs = with pkgs; [
                    patchelf
                    steamcmd
                    findutils   # Adds 'find'
                ];
                execer = with pkgs; [
                    "cannot:${steamcmd}/bin/steamcmd"
                ];
            } ''
                set -eux

                dir="${server-install-directory}"
                app_id="${steam-game-server-app-id}"
                beta_id="${steam-game-beta-id}"
                beta_password="${steam-game-beta-password}"

                # These are arguments you will always
                cmds=(
                    +force_install_dir $dir
                    +login anonymous
                    +app_update $app_id
                    validate
                )

                # Add optional beta arguments if a beta is present
                if [[ $beta_id ]]; then
                    cmds+=(-beta $beta_id)

                    # If the beta has a password...
                    if [[ $beta_password ]]; then
                        cmds+=(-betapassword $beta_password)
                    fi
                fi

                # add the final quit argument
                cmds+=(+quit)

                # Execute the Command and its Arguments
                steamcmd $cmds

                # Iterate over the downloaded files
                for f in $(find "$dir"); do

                    # Skip if not
                    # - A file
                    # - Executable
                    if ! [[ -f $f && -x $f ]]; then
                        continue
                    fi

                    # Update the interpreter to the path on NixOS.
                    patchelf --set-interpreter ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 $f || true
                done
            ''}";

            TimeoutStartSec = "180";

            ExecStart = lib.escapeShellArgs [
                "${server-install-directory}/FactoryServer.sh"
                "-multihome=0.0.0.0"                            # Need to force IPv4
                "-BeaconPort=${secrets.server-beacon-port-udp}"
                "-Port=${secrets.server-game-port-udp}"
                "-ServerQueryPort=${secrets.server-query-port-udp}"
                # https://satisfactory.fandom.com/wiki/Dedicated_servers#Command_line_options
            ];
            Nice                = "-5";
            PrivateTmp          = true;
            Restart             = "on-failure";
            User                = "satisfactory";
            Group               = "satisfactory";
            WorkingDirectory    = "~";

            # Logging Settings
            StandardOutput      = "append:${log-folder}/${log-file-stdout}";
            StandardError       = "append:${log-folder}/${log-file-stderr}";
        };

        environment = {
            # linux64 directory is required by Satisfactory.
            LD_LIBRARY_PATH     = "${server-install-directory}/linux64:${pkgs.glibc}/lib";
        };
    };

    # ...
}
```

So breaking up the 2 complicated parts of this,

First the easier one, the actual command to start the server `ExecStart`.

```nix
ExecStart = lib.escapeShellArgs [
    "${server-install-directory}/FactoryServer.sh"
    "-multihome=0.0.0.0"                            # Need to force IPv4
    "-BeaconPort=${secrets.server-beacon-port-udp}"
    "-Port=${secrets.server-game-port-udp}"
    "-ServerQueryPort=${secrets.server-query-port-udp}"
    # https://satisfactory.fandom.com/wiki/Dedicated_servers#Command_line_options
];
```

Its much cleaner to use a list of arguments to execute on service start, which just means defining a list of strings. This also gives an easier way to include variables in each argument.

Now the more complicated, `ExecStartPre`.

```nix
# Download the game
# Then fix those binaries using patchelf
ExecStartPre = "${pkgs.resholve.writeScript "steam" {
    interpreter = "${pkgs.zsh}/bin/zsh";
    inputs = with pkgs; [
        patchelf
        steamcmd
        findutils   # Adds 'find'
    ];
    execer = with pkgs; [
        "cannot:${steamcmd}/bin/steamcmd"
    ];
} ''
    set -eux

    dir="${server-install-directory}"
    app_id="${steam-game-server-app-id}"
    beta_id="${steam-game-beta-id}"
    beta_password="${steam-game-beta-password}"

    # These are arguments you will always
    cmds=(
        +force_install_dir $dir
        +login anonymous
        +app_update $app_id
        validate
    )

    # Add optional beta arguments if a beta is present
    if [[ $beta_id ]]; then
        cmds+=(-beta $beta_id)

        # If the beta has a password...
        if [[ $beta_password ]]; then
            cmds+=(-betapassword $beta_password)
        fi
    fi

    # add the final quit argument
    cmds+=(+quit)

    # Execute the Command and its Arguments
    steamcmd $cmds

    # Iterate over the downloaded files
    for f in $(find "$dir"); do

        # Skip if not
        # - A file
        # - Executable
        if ! [[ -f $f && -x $f ]]; then
            continue
        fi

        # Update the interpreter to the path on NixOS.
        patchelf --set-interpreter ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 $f || true
    done
''}";
```

> [!CAUTION]
> I am still learning NixOS so this may not be the full story.

To explain this I have to explain NixOS a bit. NixOS is a special linux operating system built around the package manager `Nix` and that each package is isolated from each other when downloaded. This is then used to allow true reproducibility by versioning the packages used by each executable. This means that two different applications running on the same NixOS can have different package versions installed at the same time. This also means that anyone can share the collection of packages used to run a particular software on Nix, and give it to someone else. Who now has the ability to fully reproduces any code ran.

The downside is that the vast majority of all existing binaries compiled expect core libraries or packages, to be in the standard location. *The traditional way its always done*. So Nix needs to change all binaries to fix the path to any dependency of the binary to match the one Nix has. [Read more Binaries on NixOS](https://nixos.wiki/wiki/Packaging/Binaries).

Nix has multiple ways to fix the paths automagically, but the one I used was [`patchelf`](https://github.com/NixOS/patchelf).

So backing up as to what this block does. It does 2 steps to prepare all the files for the actual execution of the Satisfactory server:

1. Install the game files from steam
2. Iterate over all downloaded files
    - If a file is an executable, run patchelf on it to fix the binary

Which is all a mini script being run inline of the `ExecStartPre`. There are some arguments ahead of this to set up what libraries (patchelf, steamcmd, findutils) are used in the script. Which would normally not exist as the script would be executed in isolation.

### 3.d - Firewall

Next we add a simple firewall rule for the game ports which the game server was configured to start on.

```nix
let
    # ...
in
{
    # ...

    networking.firewall.allowedUDPPorts = [
        # # https://satisfactory.fandom.com/wiki/Dedicated_servers#Port_forwarding_and_firewall_settings
        # Satisfactory Beacon Port
        (lib.toInt secrets.server-beacon-port-udp)
        # Satisfactory Game Port
        (lib.toInt secrets.server-game-port-udp)
        # Satisfactory Query Port
        (lib.toInt secrets.server-query-port-udp)
    ];

    # ...
}
```

### 3.e - Logging

Finally we add automatic log rotation for the logs which will be generated by the service.

```nix
let
    # ...
in
{
    # ...

    # Enable Logrotate
    services.logrotate = {
        enable = true;
    };

    # Add Logrotate config for satisfactory stdout logs
    services.logrotate.settings.satisfactory_stdout = {
        files           = "${log-folder}/${log-file-stdout}";

        compress        = true;
        create          = "640 satisfactory satisfactory";
        dateext         = true;
        delaycompress   = true;
        frequency       = "daily";
        missingok       = true;
        notifempty      = true;
        su              = "satisfactory satisfactory";
        rotate          = 31;
    };

    # Add Logrotate config for satisfactory stderr logs
    services.logrotate.settings.satisfactory_stderr = {
        files           = "${log-folder}/${log-file-stderr}";

        compress        = true;
        create          = "640 satisfactory satisfactory";
        dateext         = true;
        delaycompress   = true;
        frequency       = "daily";
        missingok       = true;
        notifempty      = true;
        su              = "satisfactory satisfactory";
        rotate          = 31;
    };

    # Pre-Create Files and Folders
    systemd.tmpfiles.rules = [
        # Game Install Directory
        "d ${server-install-directory} 0750 satisfactory satisfactory -"

        # Log Files and Folders
        "d ${log-folder} 0770 satisfactory satisfactory -"
        "f ${log-folder}/${log-file-stdout} 0640 satisfactory satisfactory -"
        "f ${log-folder}/${log-file-stderr} 0640 satisfactory satisfactory -"
    ];
}
```

## 4 - `system-configs.nix`

The system config is much simpler. It only:

- Enabled SSH so you can log in
- Enabled the firewall
  - Allows SSH through said firewall
- Configure the system with a static IPv4 address
- And enable QEMU Guest Agent
  - I am running this all using Proxmox as my hypervisor, and this is its guest agent.

```nix
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
    services.openssh.enable             = true;
    networking.firewall.enable          = true;
    networking.firewall.allowedTCPPorts = [
        (lib.toInt secrets.system-ssh-port)
    ];

    # Configure System with Static IP
    networking.interfaces.eth0.ipv4.addresses = [ {
        address      = secrets.system-ipv4-address;
        prefixLength = secrets.system-ipv4-prefix;
    } ];
    # This uses eth0, you will want to check which device you are using on your system
    # Check using 'ip a' and looking for the name of the device you are changing the settings of

    # Remaining network settings
    networking.defaultGateway = secrets.system-ipv4-gateway;
    networking.nameservers    = secrets.system-ipv4-dns-list;
    networking.hostName       = secrets.system-hostname;
    # Make sure to comment out the same config from the /etc/nixos/configuration.nix file

    # Enable QEMU Guest Agent
    # Used by Proxmox
    services.qemuGuest.enable = true;
}
```
