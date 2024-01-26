# Simple Ubuntu Satisfactory Server

## Local README Navigation

- [*root directory*](../../README.md)
- [/game-server-satisfactory](../README.md)
  - [simple-ubuntu-configs/](./README.md)
    - A simple Ubuntu config and help document to install a Satisfactory server on Ubuntu

## Note

> [!NOTE]
> Last built on Ubuntu 23.10, using minimal server install

### Expected Outputs

> [!IMPORTANT]
> Expected outputs are provided in [example-output.md](example-output.md)

## Requirements

> [!IMPORTANT]
> This script assumes the current user is a part of the `sudoers` group
>
> This guide does not assume the user has logged into the `root` account as using the `root` account is bad practice.
>
> This guide instead prepends "sudo" in front of any command requiring elevated permissions.
>
> Read more about the sudoers group: <https://linuxize.com/post/how-to-add-user-to-sudoers-in-ubuntu/>

## 0. Update and Upgrades

While installing system and package updates is an ***optional*** step, it is still a best practice to do.

> [!TIP]
> It is suggested to update all packages for security purposes especially as this will be a game server which could have vulnerabilities.

```bash
sudo apt update
sudo apt upgrade -y
```

> [!TIP]
> It is also suggest to install any Operating System upgrade and generally clean up the system before proceeding

```bash
sudo apt dist-upgrade -y
sudo apt autoremove -y
sudo apt autoclean -y
```

> [!CAUTION]
> This will shuts down and reboot the server. Make sure nothing else is running and might be lost

```bash
sudo shutdown -r
```

## 1. Install SteamCMD

Now we will install SteamCMD directly from their guide.
<https://developer.valvesoftware.com/wiki/SteamCMD#Ubuntu>

### Prepare Repository

```bash
sudo apt update
sudo add-apt-repository multiverse -y
sudo dpkg --add-architecture i386
sudo apt-get update
```

### Prepare SteamCMD install Questions

When installing steam the system asks you to accept 2 questions which would normally interrupt an "unattended" system.

We can prepare answers to these questions using `debconf-set-selections`

```bash
# Prep unattended accept of license
echo steamcmd steam/question select "I AGREE" | sudo debconf-set-selections
echo steamcmd steam/license note '' | sudo debconf-set-selections
```

### Install steamcmd

```bash
sudo apt-get install steamcmd -y
```

## 2. Set up Firewall Rules

It is a best practice to use a Firewall whenever possible.

### Setting Variables

If you intend to run the server on a non default port you would want to change the ports you are using here.

> [!IMPORTANT]
> If you intend to connect to this server from outside of your LAN (local area network), these 3 ports will need to ***all*** be forwarded from your router to this system running the dedicated server.

```bash
GAME_PORT_QUERY=15777
GAME_PORT_BEACON=15000
GAME_PORT_GAME=7777
UFW_PROFILE=satisfactory-firewall
UFW_APPLICATION_PROFILE_FILE="~/$UFW_PROFILE.conf"
UFW_APPLICATION_FOLDER="/etc/ufw/applications.d/"
```

> [!IMPORTANT]
> `GAME_PORT_QUERY` is the port users will initially connect to your server on. Make sure to check the games official networking guide.
> <https://satisfactory.fandom.com/wiki/Dedicated_servers#Port_forwarding_and_firewall_settings>

### Install and Enable `ufw`

Make sure you have `ufw` the *Uncomplicated Firewall* installed

```bash
sudo apt install ufw -y
```

Start `ufw` service, and make sure it starts at boot in the future.

```bash
# Start and enable service
sudo systemctl start ufw
sudo systemctl enable ufw
```

### Create a `ufw` application profile for the servers ports

An example of the final config can be found in this repo.

`./etc/ufw/applications.d/satisfactory-firewall.conf`

> [!NOTE]
> Here we are creating a ufw "Application Profile" more information can be found on this great StackExchange post.
> <https://askubuntu.com/a/488647>
>
> `HEREDOC` blocks are a great way to create multiline strings. Bash variables can be used to help automate the contents of the file.
> Read more: <https://linuxize.com/post/bash-heredoc/>

```bash
# Create an application firewall.
# See simple-ubuntu-configs/etc/ufw/applications.d
cat << HEREDOC_UFW_APPLICATION > $UFW_APPLICATION_PROFILE_FILE
[$UFW_PROFILE]
title=Satisfactory
description=Satisfactory Dedicated Server Firewall Rules
ports=$GAME_PORT_QUERY/udp|$GAME_PORT_BEACON/udp|$GAME_PORT_GAME/udp
HEREDOC_UFW_APPLICATION

# copy the file you just created to the ufw applications folder
sudo mv $UFW_APPLICATION_PROFILE_FILE $UFW_APPLICATION_FOLDER
```

> [!NOTE]
> The following is an example Satisfactory Firewall Application
>
> Check the contents using
>
> ```bash
> cat $SYSTEMD_SERVICE_FOLDER$GAME_SERVER_SERVICE_FILE
> ```
>
> An example is also located in this repo `./etc/ufw/applications.d/satisfactory-firewall.conf`
>
> ```ini
> [satisfactory-firewall]
> title=Satisfactory
> description=Satisfactory Dedicated Server Firewall Rules
> ports=15777/udp|15000/udp|7777/udp
> ```

### Set Firewall Rules

> [!TIP]
> We will be allowing all outbound, while it is more complicated a more secure approach would be to limit where the server can go. But that would involve a good bit of watching what network traffic is generated outbound and filtering.
>
> Alternatively if you are interested in limiting the system from initiating connections to other servers on your network this could be configured here.

```bash
# Start and enable service
sudo systemctl start ufw
sudo systemctl enable ufw

# Define default rules of the firewall
sudo ufw default allow outgoing     # By default - Allow Outgoing
sudo ufw default deny incoming      # By default - Deny Incoming

# Add exceptions to those rules
sudo ufw allow ssh                  # Allow SSH if this is your management strategy
sudo ufw allow $UFW_PROFILE         # Allow ports listed in the above satisfactory

# Verify rule set are correct
sudo ufw show added
```

### Enabling Firewall

> [!CAUTION]
> **Ensure any inbound ports you may be using to manage this system has been allowed before continuing!**
>
> Failure to do so may result in you be locked out of your server.
>
> Common Management Solutions:
>
> - Physical Keyboard and mouse ✓
>   - You are good already
> - SSH, will be allowed ✓
>   - If you are using a non default port manually set the number using:
>     - `sudo ufw allow 22/tcp`
>     - replace `22` with your alternative port number
> - RDP, not added X
>   - Add using `sudo ufw allow rdp` or `sudo ufw allow 3389/tcp`
>
> Read more about ufw <https://ubuntu.com/server/docs/security-firewall>

```bash
# Turn on the firewall
sudo ufw enable

# Check status of the active rules
sudo ufw status
```

## 3. Create game user

```bash
GAME_USER="satisfactory"

sudo useradd --system --create-home --shell /bin/false $GAME_USER
```

> [!NOTE]
> Explanation of what each argument from the above `useradd` command does:
>
> - `--system`
>   - Create a system account instead of user account (Similar to "service" account)
> - `--create-home`
>   - Create a home directory for the account
> - `--shell /bin/false`
>   - This disables direct login for this user.
>     - When the user "logs in" the shell it spawns is `/bin/false` which exits immediately instead of giving a shell like `/bin/bash`, `/bin/zsh`, or `/bin/sh`
> - `$GAME_USER`
>   - The variable holding the name of the user being created.

## 4. Create Important Folders

Create a few variables to make future commands make more sense. This also makes it easier for these values to be changed later

```bash
SATISFACTORY_INSTALL_FOLDER="/var/lib/satisfactory"

sudo mkdir -p $SATISFACTORY_INSTALL_FOLDER
```

> [!TIP]
> `mkdir -p FOLDER` will create all folders in the path, and not error if for example the top most directory does not exist.

### Give ownership of the folders to the Game Server's Service Account

```bash
sudo chown -R $GAME_USER:$GAME_USER $SATISFACTORY_INSTALL_FOLDER
```

## 5. Test the Install of the as the service account

> [!TIP]
> Testing the install helps to isolate problems by validating the install works.
>
> In the case of a slow network connection the first install could take some time. Systemd may inadvertently kill the service before it can finish installing and validating for the first time.

```bash
sudo --user=$GAME_USER /usr/games/steamcmd +force_install_dir "$SATISFACTORY_INSTALL_FOLDER" +login anonymous +app_update 1690800 validate +quit
```

> [!NOTE]
> Because the service account was created with the shell `--shell /bin/false` the service account can not be logged into using `su` or other login methods.
>
> We can still run commands as the service account using `sudo --user=USERNAME COMMAND` to run a `COMMAND` as the user `USERNAME`.
>
> This does require the current user to have `sudo` permissions.

## 6. Configure Dedicated Server as a Service

> [!TIP]
> Satisfactory Dedicated Server is able to be configured as a Systemd service.
>
> Read the wiki guide: <https://satisfactory.fandom.com/wiki/Dedicated_servers/Running_as_a_Service>

Using a heredoc again to help incorporate variables into the file content.

### Set some variables

```bash
SYSTEMD_SERVICE_FOLDER="/etc/systemd/system"
GAME_SERVER_SERVICE="satisfactory"
GAME_SERVER_SERVICE_FILE="$GAME_SERVER_SERVICE.service"
```

> [!IMPORTANT]
> **Writers Note**
>
> While it ***may not be best practice*** to include an application service in the `/etc/systemd/system/` folder, I personally have not tested the other locations where services are to be installed to.
>
> From what I have read so far it is more of a best practice which folder services go in based on importance.
>
> The video I learned this fact from: <https://www.youtube.com/watch?v=Kzpm-rGAXos>
>
> by [LearnLinuxTV on Youtube](https://www.youtube.com/@LearnLinuxTV)

```bash
cat << HEREDOC_GAME_SERVER_SERVICE > $GAME_SERVER_SERVICE_FILE
[Unit]
Description=Satisfactory dedicated server
Wants=network-online.target
After=syslog.target network.target nss-lookup.target network-online.target

[Service]
# =========================================================
# Environment Config
# =========================================================
User=$GAME_USER
Group=$GAME_USER
WorkingDirectory=$SATISFACTORY_INSTALL_FOLDER
Environment="LD_LIBRARY_PATH=./linux64"

# =========================================================
# Start/Stop/Restart
# =========================================================
Restart=on-failure

# Steam takes the longest to start while doing validate
# Depending on CPU speed/Disk Speed/Network this time may vary
# I have seen that 3 minutes works, but you can increase this if the service does not start in the allotted time
TimeoutStartSec=180

# Before starting the main "service"
# We install/validate the steam game
ExecStartPre=/usr/games/steamcmd +force_install_dir "$SATISFACTORY_INSTALL_FOLDER" +login anonymous +app_update 1690800 validate +quit

# Start the game server
# Note '-multihome=0.0.0.0' has been needed to fix an IPv6 issue, we are fixing this by forcing the server to bind to just ipv4 addresses
ExecStart=$SATISFACTORY_INSTALL_FOLDER/FactoryServer.sh -multihome=0.0.0.0 -ServerQueryPort=$GAME_PORT_QUERY -BeaconPort=$GAME_PORT_BEACON -Port=$GAME_PORT_GAME

[Install]
WantedBy=multi-user.target
HEREDOC_GAME_SERVER_SERVICE

# copy the file you just created to the systemd folder
sudo mv $GAME_SERVER_SERVICE_FILE $SYSTEMD_SERVICE_FOLDER
```

> [!NOTE]
> The following is an example of what the Satisfactory Service file should look like
>
> Check the contents using
>
> ```bash
> cat $SYSTEMD_SERVICE_FOLDER$GAME_SERVER_SERVICE_FILE
> ```
>
> An example is also located in this repo `./etc/systemd/system/satisfactory.service`
>
> ```ini
> [Unit]
> Description=Satisfactory dedicated server
> Wants=network-online.target
> After=syslog.target network.target nss-lookup.target network-online.target
>
> [Service]
> # =========================================================
> # Environment Config
> # =========================================================
> User=satisfactory
> Group=satisfactory
> WorkingDirectory=/var/lib/satisfactory
> Environment="LD_LIBRARY_PATH=./linux64"
>
> # =========================================================
> # Start/Stop/Restart
> # =========================================================
> Restart=on-failure
>
> # Steam takes the longest to start while doing validate
> # Depending on CPU speed/Disk Speed/Network this time may vary
> # I have seen that 3 minutes works, but you can increase this if the service does not start in the allotted time
> TimeoutStartSec=180
>
> # Before starting the main "service"
> # We install/validate the steam game
> ExecStartPre=/usr/games/steamcmd +force_install_dir "/var/lib/satisfactory" +login anonymous +app_update 1690800 validate +quit
>
> # Start the game server
> # Note '-multihome=0.0.0.0' has been needed to fix an IPv6 issue, we are fixing this by forcing the server to bind to just ipv4 addresses
> ExecStart=/var/lib/satisfactory/FactoryServer.sh -multihome=0.0.0.0 -ServerQueryPort=15777 -BeaconPort=15000 -Port=7777
>
> [Install]
> WantedBy=multi-user.target
> ```

### Reload services

While we have created the service file we need to now ask systemd to refresh its knowledge of what service files exists.

```bash
sudo systemctl daemon-reload
```

### Enable and Start service

```bash
# Enable the service, this starts the service when the system boots up automatically
sudo systemctl enable $GAME_SERVER_SERVICE

# Start the service right now
sudo systemctl start $GAME_SERVER_SERVICE
```

### Check the service status

```bash
sudo systemctl status $GAME_SERVER_SERVICE
```

Example output:

```bash
#TODO
```

## Optional Tweaks

> [!IMPORTANT]
> These optional changes expect that certain variables used above are still loaded in your session.
>
> If not re assign them using these variables
>
> ```bash
> GAME_USER="satisfactory"
> SATISFACTORY_INSTALL_FOLDER="/var/lib/satisfactory"
> GAME_PORT_QUERY="15777"
> GAME_PORT_BEACON="15000"
> GAME_PORT_GAME="7777"
> SYSTEMD_SERVICE_FOLDER="/etc/systemd/system"
> GAME_SERVER_SERVICE="satisfactory"
> GAME_SERVER_SERVICE_FILE="$GAME_SERVER_SERVICE.service"
> ```

### A. Configure Logging Directory & Logrotate

Adding Logging to a separate file helps to collect logs in a central place and with `logrotate` lets you automatically rotate these logs daily to keep a searchable record of the server logs.

#### Variables

```bash
SATISFACTORY_LOG_FOLDER="/var/log/satisfactory"
SATISFACTORY_LOGROTATE_CONFIG_FILE="satisfactory.conf"
LOGROTATE_CONFIG_FOLDER="/etc/logrotate.d/"
SATISFACTORY_LOG_STANDARD_OUT="stdout.log"
SATISFACTORY_LOG_STANDARD_ERROR="stderr.log"
```

#### Create Logging Directories

These steps are the same as above for creating the install directory

```bash
sudo mkdir -p $SATISFACTORY_LOG_FOLDER
sudo touch $SATISFACTORY_LOG_FOLDER/$SATISFACTORY_LOG_STANDARD_OUT
sudo touch $SATISFACTORY_LOG_FOLDER/$SATISFACTORY_LOG_STANDARD_ERROR
sudo chown -R $GAME_USER:$GAME_USER $SATISFACTORY_LOG_FOLDER
```

Check the permissions

```bash
sudo ls -al $SATISFACTORY_LOG_FOLDER
```

#### Create Logrotate Config File

> [!TIP]
> Read more about Logrotate: <https://linux.die.net/man/8/logrotate>

```bash
# Create a logrotate config
cat << HEREDOC_LOGROTATE_CONFIG > $SATISFACTORY_LOGROTATE_CONFIG_FILE
$SATISFACTORY_LOG_FOLDER/*.log {
    # When to rotate, or not
    daily       # Check daily
    missingok   # Its ok if the file is missing
    notifempty  # Skip if the file is empty

    # Compress the log
    compress

    # Create a new file with the following permissions
    create 0644 $GAME_USER $GAME_USER

    # The rotated file should have a date stamp appended to its name.
    dateext
}
HEREDOC_LOGROTATE_CONFIG

# copy the file you just created to the ufw applications folder
sudo mv $SATISFACTORY_LOGROTATE_CONFIG_FILE $LOGROTATE_CONFIG_FOLDER
```

> [!NOTE]
> The following is an example Satisfactory Logrotate config file
>
> Check the contents using
>
> ```bash
> cat $LOGROTATE_CONFIG_FOLDER$SATISFACTORY_LOGROTATE_CONFIG_FILE
> ```
>
> Also find an example file in this repo: `./etc/logrotate.d`
>
> ```ini
> /var/log/satisfactory/*.log {
>     # When to rotate, or not
>     daily       # Check daily
>     missingok   # Its ok if the file is missing
>     notifempty  # Skip if the file is empty
>
>     # Compress
>     compress
>
>     # Create a new file with the following permissions
>     create 0644 satisfactory satisfactory
>
>     # The rotated file should have a date stamp appended to its name.
>     dateext
> }
> ```

#### Dry run the new logrotate config

```bash
# Test the new Logrotate config
logrotate $LOGROTATE_CONFIG_FOLDER$SATISFACTORY_LOGROTATE_CONFIG_FILE --debug
```

Expected Output

```txt
# TODO
```

#### Update Systemd Service file with Logging included

```bash
SYSTEMD_SERVICE_FOLDER="/etc/systemd/system"
GAME_SERVER_SERVICE="satisfactory"
GAME_SERVER_SERVICE_FILE="$GAME_SERVER_SERVICE.service"
```

> [!IMPORTANT]
> **Writers Note**
>
> While it ***may not be best practice*** to include an application service in the `/etc/systemd/system/` folder, I personally have not tested the other locations where services are to be installed to.
>
> From what I have read so far it is more of a best practice which folder services go in based on importance.
>
> The video I learned this fact from: <https://www.youtube.com/watch?v=Kzpm-rGAXos>
>
> by [LearnLinuxTV on Youtube](https://www.youtube.com/@LearnLinuxTV)

```bash
cat << HEREDOC_GAME_SERVER_SERVICE > $GAME_SERVER_SERVICE_FILE
[Unit]
Description=Satisfactory dedicated server
Wants=network-online.target
After=syslog.target network.target nss-lookup.target network-online.target

[Service]
# =========================================================
# Environment Config
# =========================================================
User=$GAME_USER
Group=$GAME_USER
WorkingDirectory=$SATISFACTORY_INSTALL_FOLDER
Environment="LD_LIBRARY_PATH=./linux64"

# =========================================================
# Logging
# =========================================================
# Make sure to implement logrotate!!!!!
StandardOutput=append:$SATISFACTORY_LOG_FOLDER/$SATISFACTORY_LOG_STANDARD_OUT
StandardError=append:$SATISFACTORY_LOG_FOLDER/$SATISFACTORY_LOG_STANDARD_ERROR

# =========================================================
# Start/Stop/Restart
# =========================================================
Restart=on-failure

# Steam takes the longest to start while doing validate
# Depending on CPU speed/Disk Speed/Network this time may vary
# I have seen that 3 minutes works, but you can increase this if the service does not start in the allotted time
TimeoutStartSec=180

# Before starting the main "service"
# We install/validate the steam game
ExecStartPre=/usr/games/steamcmd +force_install_dir "$SATISFACTORY_INSTALL_FOLDER" +login anonymous +app_update 1690800 validate +quit

# Start the game server
# Note '-multihome=0.0.0.0' has been needed to fix an IPv6 issue, we are fixing this by forcing the server to bind to just ipv4 addresses
ExecStart=$SATISFACTORY_INSTALL_FOLDER/FactoryServer.sh -multihome=0.0.0.0 -ServerQueryPort=$GAME_PORT_QUERY -BeaconPort=$GAME_PORT_BEACON -Port=$GAME_PORT_GAME

[Install]
WantedBy=multi-user.target
HEREDOC_GAME_SERVER_SERVICE

# copy the file you just created to the systemd folder
sudo mv $GAME_SERVER_SERVICE_FILE $SYSTEMD_SERVICE_FOLDER
```

> [!NOTE]
> The following is an example of what the Satisfactory Service file should look like
>
> Check the contents using
>
> ```bash
> cat $SYSTEMD_SERVICE_FOLDER$GAME_SERVER_SERVICE_FILE
> ```
>
> An example is also located in this repo `./etc/systemd/system/satisfactory.service`
>
> ```ini
> [Unit]
> Description=Satisfactory dedicated server
> Wants=network-online.target
> After=syslog.target network.target nss-lookup.target network-online.target
>
> [Service]
> # =========================================================
> # Environment Config
> # =========================================================
> User=satisfactory
> Group=satisfactory
> WorkingDirectory=/var/lib/satisfactory
> Environment="LD_LIBRARY_PATH=./linux64"
>
> # =========================================================
> # Logging
> # =========================================================
> # Make sure to implement logrotate!!!!!
> StandardOutput=append:/var/log/satisfactory/stdout.log
> StandardError=append:/var/log/satisfactory/stderr.log
>
> # =========================================================
> # Start/Stop/Restart
> # =========================================================
> Restart=on-failure
>
> # Steam takes the longest to start while doing validate
> # Depending on CPU speed/Disk Speed/Network this time may vary
> # I have seen that 3 minutes works, but you can increase this if the service does not start in the allotted time
> TimeoutStartSec=180
>
> # Before starting the main "service"
> # We install/validate the steam game
> ExecStartPre=/usr/games/steamcmd +force_install_dir "/var/lib/satisfactory" +login anonymous +app_update 1690800 validate +quit
>
> # Start the game server
> # Note '-multihome=0.0.0.0' has been needed to fix an IPv6 issue, we are fixing this by forcing the server to bind to just ipv4 addresses
> ExecStart=/var/lib/satisfactory/FactoryServer.sh -multihome=0.0.0.0 -ServerQueryPort=15777 -BeaconPort=15000 -Port=7777
>
> [Install]
> WantedBy=multi-user.target
> ```

### Reload and Restart Services with Logging Added

While we have created the service file we need to now ask systemd to refresh its knowledge of what service files exists.

```bash
sudo systemctl daemon-reload
sudo systemctl restart $GAME_SERVER_SERVICE
sudo systemctl status $GAME_SERVER_SERVICE
```

> [!IMPORTANT]
> You will no longer see most of the Satisfactory logs in `journalctl` and the `systemctl status` commands.
>
> Instead they have been piped to the new Log Files you have specified.
> You can read them using.
>
> ```bash
> # Standard Output
> cat /var/log/satisfactory/stdout.log
> # Standard Error
> cat /var/log/satisfactory/stderr.log
> ```

### B. Add Server Status Message to the Message Of The Day

When your user first logs in there is a message printed to the screen as a welcome. Custom messages can be added using the Message of the Day or MOTD.

> [!TIP]
> Read more about the MOTD: <https://linuxconfig.org/how-to-change-welcome-message-motd-on-ubuntu-18-04-server>

We can update this to have it print the servers status as well.

> [!NOTE]
> This script escapes the `$` using `\$` in the script when the script uses the `$` to reference a variable.

```bash
MOTD_FILE="99-satisfactory.sh"
MOTD_LOCATION="/etc/profile.d"

touch $MOTD_FILE

# Copy contents of ./etc/profile.d/99-satisfactory into file
# Note the escaped $
cat << HEREDOC_MOTD_SCRIPT > $MOTD_FILE
#!/bin/sh

# Game Server Service name
GAME_SERVER_SERVICE="$GAME_SERVER_SERVICE"

# Game Server Information
echo "===================="
echo "GAME SERVER INFO"

# Show game server status
echo "Satisfactory Server: \$(systemctl show -p SubState --value \$GAME_SERVER_SERVICE)"

# Show game server uptime/downtime
echo "Since: \$(systemctl show --property=ActiveEnterTimestamp --value \$GAME_SERVER_SERVICE)"

echo "===================="
HEREDOC_MOTD_SCRIPT

sudo cp $MOTD_FILE $MOTD_LOCATION
```

> [!NOTE]
> The following is an example of what the Satisfactory Service file should look like
>
> Check the contents using
>
> ```bash
> cat $MOTD_LOCATION/$MOTD_FILE
> ```
>
> An example is also located in this repo `./etc/systemd/system/satisfactory.service`
>
> ```bash
> #!/bin/sh
>
> # Game Server Service name
> GAME_SERVER_SERVICE="satisfactory"
>
> # Game Server Information
> echo "===================="
> echo "GAME SERVER INFO"
>
> # Show game server status
> echo "Satisfactory Server: $(systemctl show -p SubState --value $GAME_SERVER_SERVICE)"
>
> # Show game server uptime/downtime
> echo "Since: $(systemctl show --property=ActiveEnterTimestamp --value $GAME_SERVER_SERVICE)"
>
> echo "===================="
> ```

Next time you log in you will see the following at the end just before your prompt:

```txt
====================
GAME SERVER INFO
Satisfactory Server: running
Since: Thu 2024-01-25 23:45:43 UTC
====================
```
