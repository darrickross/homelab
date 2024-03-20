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

## Explaining Nix Config

### `example-secrets.nix`

> [!IMPORTANT]
> This is an example file and is not intended to be used. The real `secrets.nix` is added as a file to be ignored, and not included in source control.

This is a file containing variables to be used in the other nix configs. They are all important variables like port numbers and ip addresses which are a security risk to distribute directly.

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

### `system-configs.nix`
