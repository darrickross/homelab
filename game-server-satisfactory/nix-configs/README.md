# Nixos Config

This directory represents an example of how to set up a Satisfactory server on NixOS. This is much better than my initial [simple-ubuntu-configs/](../simple-ubuntu-configs/README.md) deployment of satisfactory. NixOS represents an Infrastructure as Code (IaC), or really Configuration as Code (CaC??). Which given the host a massive ability to control what is deployed, and manage that in git (or other source control) instead of manually changing somethings on the server.

To back up a bit and really step onto a soap box for a paragraph. [Infrastructure as Code](https://aws.amazon.com/what-is/iac/) is a time savings way to manage resources. If its in code, or really in git (or other source control), that can be tracked. Rolled back. Branched. Or any other 'action' expected of modern software design. With Infrastructure as Code there is no question of what was deployed. The same thing can be deployed to multiple places with the exact same structures and results. The security savings are also massive. Static code analysis tools can be let loose on infrastructure if that infrastructure is in code. Meaning I can get warnings if the combination of settings I am about to do is either missing a critical security piece, or is plain inefficient.

Now realistically, what I have going on here is not a massive cost savings by deploying with Infrastructure as Code. But what it does do is build the foundations for my later ability to [spin 100% of my non-core infrastructure using automation like GitHub actions, or other CI/CD runner](https://www.youtube.com/watch?v=tIWDpG7sNTU). Having this automation trigger on detection of a change to my infrastructure. Meaning I can spin up, spin down, and roll back, *automagically*.

This rant may move somewhere else, maybe a dedicated rants folder at the root.

## Relative Folder Structure

- [*root directory*](../../README.md)
  - [/game-server-satisfactory](../README.md)
    - [nix-configs/](./README.md) - ***YOU ARE HERE***
      - `example-secrets.nix` - Set of configuration settings which are best left secret.
      - `satisfactory.nix` - Core Nix config which sets up Satisfactory.
      - `system-configs.nix` - Core system configuration settings.
    - [simple-ubuntu-configs/](../simple-ubuntu-configs/README.md)

## Attribution

Initially I used the example [Valheim Server on NixOS v2](https://kevincox.ca/2022/12/09/valheim-server-nixos-v2/). But I have since branched from the initial guide as I slowly start to better understand NixOS.

## How to use these configs

After you spin up NixOS on the system you will be hosting Satisfactory on. You will want to open the system and transfer the 3 files to it

1. `satisfactory.nix`
2. `secrets.nix`
    - This file is not initially provided as it contains values which should be secret and not committed to version control.
    - Copy the `example-secrets.nix` and name it `secrets.nix` updating any values as needed.
3. `system-configs.nix`

After transferring these files to the NixOS system we will move them to the root config directory `/etc/nixos/`.

> [!IMPORTANT]
> `/etc/nixos/` is a root user controlled directory, aka `sudo` or the less secure way, `su` to root.

&

> [!NOTE]
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

You can do this with you favorite text editor. But most may not come installed by default in NixOS.

```txt
[manager@satisfactory-prod:~]$ vi
vi: command not found

[manager@satisfactory-prod:~]$ nano

[manager@satisfactory-prod:~]$ vim
vim: command not found

[manager@satisfactory-prod:~]$
```

As you can see, `nano` is the only editor in this list which is installed by default on NixOS.

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

Finally we will need to update the system by running a system rebuild

```bash
sudo nixos-rebuild switch
```

- TODO add Output from fresh build

This will rebuild the system based on the current state of the `/etc/nixos/configuration.nix` config. This will also include any additional files included using the `imports` block.

Assuming everything built successfully you can see logs located in log directory for the satisfactory server where the config specified in `satisfactory.nix` under the variable `log-folder`.

You can also check the systemctl status of the service using:

```bash
sudo systemctl status satisfactory
```

- TODO add Output from fresh build

## Explaining Nix Config

### `example-secrets.nix`

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

### `satisfactory.nix`

#### Variables

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

#### Service Account

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

#### Systemd Service for Satisfactory

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

#### Firewall

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

#### Logging

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

### `system-configs.nix`

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
