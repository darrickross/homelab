# Example Output

This output is from steps from the [README](README.md) in this directory. Timestamps are relative to when this guide was last tested.

## 1. Install SteamCMD

### Prepare Repository

```bash
sudo apt update
sudo add-apt-repository multiverse -y
sudo dpkg --add-architecture i386
sudo apt-get update
```

```txt
Hit:1 http://security.ubuntu.com/ubuntu mantic-security InRelease
Hit:2 http://archive.ubuntu.com/ubuntu mantic InRelease
Hit:3 http://archive.ubuntu.com/ubuntu mantic-updates InRelease
Hit:4 http://archive.ubuntu.com/ubuntu mantic-backports InRelease
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
All packages are up to date.
Adding component(s) 'multiverse' to all repositories.
Hit:1 http://security.ubuntu.com/ubuntu mantic-security InRelease
Hit:2 http://archive.ubuntu.com/ubuntu mantic InRelease
Hit:3 http://archive.ubuntu.com/ubuntu mantic-updates InRelease
Hit:4 http://archive.ubuntu.com/ubuntu mantic-backports InRelease
Reading package lists... Done
Hit:1 http://security.ubuntu.com/ubuntu mantic-security InRelease
Hit:2 http://archive.ubuntu.com/ubuntu mantic InRelease
Hit:3 http://archive.ubuntu.com/ubuntu mantic-updates InRelease
Hit:4 http://archive.ubuntu.com/ubuntu mantic-backports InRelease
Get:5 http://security.ubuntu.com/ubuntu mantic-security/main i386 Packages [103 kB]
Get:6 http://archive.ubuntu.com/ubuntu mantic/main i386 Packages [1040 kB]
Get:7 http://security.ubuntu.com/ubuntu mantic-security/restricted i386 Packages [19.9 kB]
Get:8 http://security.ubuntu.com/ubuntu mantic-security/universe i386 Packages [76.9 kB]
Get:9 http://security.ubuntu.com/ubuntu mantic-security/multiverse i386 Packages [980 B]
Get:10 http://archive.ubuntu.com/ubuntu mantic/restricted i386 Packages [32.3 kB]
Get:11 http://archive.ubuntu.com/ubuntu mantic/universe i386 Packages [8339 kB]
Get:12 http://archive.ubuntu.com/ubuntu mantic/multiverse i386 Packages [116 kB]
Get:13 http://archive.ubuntu.com/ubuntu mantic-updates/main i386 Packages [136 kB]
Get:14 http://archive.ubuntu.com/ubuntu mantic-updates/restricted i386 Packages [21.1 kB]
Get:15 http://archive.ubuntu.com/ubuntu mantic-updates/universe i386 Packages [95.2 kB]
Get:16 http://archive.ubuntu.com/ubuntu mantic-updates/multiverse i386 Packages [1648 B]
Get:17 http://archive.ubuntu.com/ubuntu mantic-backports/universe i386 Packages [2868 B]
Fetched 9984 kB in 3s (3807 kB/s)
Reading package lists... Done
```

### Prepare SteamCMD install Questions

```bash
# Prep unattended accept of license
echo steamcmd steam/question select "I AGREE" | sudo debconf-set-selections
echo steamcmd steam/license note '' | sudo debconf-set-selections
```

> [!IMPORTANT]
> Expecting no output

### Install steamcmd

```bash
sudo apt-get install steamcmd -y
```

```txt
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  gcc-13-base:i386 libc6:i386 libcom-err2:i386 libgcc-s1:i386 libgssapi-krb5-2:i386 libidn2-0:i386 libk5crypto3:i386 libkeyutils1:i386 libkrb5-3:i386 libkrb5support0:i386 libnsl2:i386 libnss-nis:i386 libnss-nisplus:i386 libssl3:i386 libstdc++6:i386 libtirpc3:i386 libunistring2:i386
Suggested packages:
  glibc-doc:i386 locales:i386 krb5-doc:i386 krb5-user:i386 steam:i386
The following NEW packages will be installed:
  gcc-13-base:i386 libc6:i386 libcom-err2:i386 libgcc-s1:i386 libgssapi-krb5-2:i386 libidn2-0:i386 libk5crypto3:i386 libkeyutils1:i386 libkrb5-3:i386 libkrb5support0:i386 libnsl2:i386 libnss-nis:i386 libnss-nisplus:i386 libssl3:i386 libstdc++6:i386 libtirpc3:i386 libunistring2:i386 steamcmd:i386
0 upgraded, 18 newly installed, 0 to remove and 0 not upgraded.
Need to get 8935 kB of archives.
After this operation, 31.3 MB of additional disk space will be used.
Get:1 http://archive.ubuntu.com/ubuntu mantic/main i386 gcc-13-base i386 13.2.0-4ubuntu3 [43.7 kB]
Get:2 http://archive.ubuntu.com/ubuntu mantic/main i386 libgcc-s1 i386 13.2.0-4ubuntu3 [71.7 kB]
Get:3 http://archive.ubuntu.com/ubuntu mantic/main i386 libc6 i386 2.38-1ubuntu6 [2999 kB]
Get:4 http://archive.ubuntu.com/ubuntu mantic/main i386 libstdc++6 i386 13.2.0-4ubuntu3 [841 kB]
Get:5 http://archive.ubuntu.com/ubuntu mantic/multiverse i386 steamcmd i386 0~20180105-5 [1493 kB]
Get:6 http://archive.ubuntu.com/ubuntu mantic/main i386 libcom-err2 i386 1.47.0-2ubuntu1 [22.7 kB]
Get:7 http://archive.ubuntu.com/ubuntu mantic/main i386 libkrb5support0 i386 1.20.1-3ubuntu1 [37.0 kB]
Get:8 http://archive.ubuntu.com/ubuntu mantic/main i386 libk5crypto3 i386 1.20.1-3ubuntu1 [86.0 kB]
Get:9 http://archive.ubuntu.com/ubuntu mantic/main i386 libkeyutils1 i386 1.6.3-2 [9734 B]
Get:10 http://archive.ubuntu.com/ubuntu mantic-updates/main i386 libssl3 i386 3.0.10-1ubuntu2.1 [1933 kB]
Get:11 http://archive.ubuntu.com/ubuntu mantic/main i386 libkrb5-3 i386 1.20.1-3ubuntu1 [395 kB]
Get:12 http://archive.ubuntu.com/ubuntu mantic/main i386 libgssapi-krb5-2 i386 1.20.1-3ubuntu1 [153 kB]
Get:13 http://archive.ubuntu.com/ubuntu mantic/main i386 libunistring2 i386 1.0-2 [541 kB]
Get:14 http://archive.ubuntu.com/ubuntu mantic/main i386 libidn2-0 i386 2.3.4-1 [120 kB]
Get:15 http://archive.ubuntu.com/ubuntu mantic/main i386 libtirpc3 i386 1.3.3+ds-1 [92.0 kB]
Get:16 http://archive.ubuntu.com/ubuntu mantic/main i386 libnsl2 i386 1.3.0-2build2 [46.2 kB]
Get:17 http://archive.ubuntu.com/ubuntu mantic/main i386 libnss-nis i386 3.1-0ubuntu6 [28.2 kB]
Get:18 http://archive.ubuntu.com/ubuntu mantic/main i386 libnss-nisplus i386 1.3-0ubuntu6 [23.7 kB]
Fetched 8935 kB in 1s (13.5 MB/s)
Preconfiguring packages ...
Selecting previously unselected package gcc-13-base:i386.
(Reading database ... 65588 files and directories currently installed.)
Preparing to unpack .../00-gcc-13-base_13.2.0-4ubuntu3_i386.deb ...
Unpacking gcc-13-base:i386 (13.2.0-4ubuntu3) ...
Selecting previously unselected package libgcc-s1:i386.
Preparing to unpack .../01-libgcc-s1_13.2.0-4ubuntu3_i386.deb ...
Unpacking libgcc-s1:i386 (13.2.0-4ubuntu3) ...
Selecting previously unselected package libc6:i386.
Preparing to unpack .../02-libc6_2.38-1ubuntu6_i386.deb ...
Unpacking libc6:i386 (2.38-1ubuntu6) ...
Selecting previously unselected package libstdc++6:i386.
Preparing to unpack .../03-libstdc++6_13.2.0-4ubuntu3_i386.deb ...
Unpacking libstdc++6:i386 (13.2.0-4ubuntu3) ...
Selecting previously unselected package steamcmd:i386.
Preparing to unpack .../04-steamcmd_0~20180105-5_i386.deb ...
Unpacking steamcmd:i386 (0~20180105-5) ...
Selecting previously unselected package libcom-err2:i386.
Preparing to unpack .../05-libcom-err2_1.47.0-2ubuntu1_i386.deb ...
Unpacking libcom-err2:i386 (1.47.0-2ubuntu1) ...
Selecting previously unselected package libkrb5support0:i386.
Preparing to unpack .../06-libkrb5support0_1.20.1-3ubuntu1_i386.deb ...
Unpacking libkrb5support0:i386 (1.20.1-3ubuntu1) ...
Selecting previously unselected package libk5crypto3:i386.
Preparing to unpack .../07-libk5crypto3_1.20.1-3ubuntu1_i386.deb ...
Unpacking libk5crypto3:i386 (1.20.1-3ubuntu1) ...
Selecting previously unselected package libkeyutils1:i386.
Preparing to unpack .../08-libkeyutils1_1.6.3-2_i386.deb ...
Unpacking libkeyutils1:i386 (1.6.3-2) ...
Selecting previously unselected package libssl3:i386.
Preparing to unpack .../09-libssl3_3.0.10-1ubuntu2.1_i386.deb ...
Unpacking libssl3:i386 (3.0.10-1ubuntu2.1) ...
Selecting previously unselected package libkrb5-3:i386.
Preparing to unpack .../10-libkrb5-3_1.20.1-3ubuntu1_i386.deb ...
Unpacking libkrb5-3:i386 (1.20.1-3ubuntu1) ...
Selecting previously unselected package libgssapi-krb5-2:i386.
Preparing to unpack .../11-libgssapi-krb5-2_1.20.1-3ubuntu1_i386.deb ...
Unpacking libgssapi-krb5-2:i386 (1.20.1-3ubuntu1) ...
Selecting previously unselected package libunistring2:i386.
Preparing to unpack .../12-libunistring2_1.0-2_i386.deb ...
Unpacking libunistring2:i386 (1.0-2) ...
Selecting previously unselected package libidn2-0:i386.
Preparing to unpack .../13-libidn2-0_2.3.4-1_i386.deb ...
Unpacking libidn2-0:i386 (2.3.4-1) ...
Selecting previously unselected package libtirpc3:i386.
Preparing to unpack .../14-libtirpc3_1.3.3+ds-1_i386.deb ...
Unpacking libtirpc3:i386 (1.3.3+ds-1) ...
Selecting previously unselected package libnsl2:i386.
Preparing to unpack .../15-libnsl2_1.3.0-2build2_i386.deb ...
Unpacking libnsl2:i386 (1.3.0-2build2) ...
Selecting previously unselected package libnss-nis:i386.
Preparing to unpack .../16-libnss-nis_3.1-0ubuntu6_i386.deb ...
Unpacking libnss-nis:i386 (3.1-0ubuntu6) ...
Selecting previously unselected package libnss-nisplus:i386.
Preparing to unpack .../17-libnss-nisplus_1.3-0ubuntu6_i386.deb ...
Unpacking libnss-nisplus:i386 (1.3-0ubuntu6) ...
Setting up gcc-13-base:i386 (13.2.0-4ubuntu3) ...
Setting up libgcc-s1:i386 (13.2.0-4ubuntu3) ...
Setting up libc6:i386 (2.38-1ubuntu6) ...
Setting up libstdc++6:i386 (13.2.0-4ubuntu3) ...
Setting up libkeyutils1:i386 (1.6.3-2) ...
Setting up steamcmd:i386 (0~20180105-5) ...
Setting up libssl3:i386 (3.0.10-1ubuntu2.1) ...
Setting up libunistring2:i386 (1.0-2) ...
Setting up libidn2-0:i386 (2.3.4-1) ...
Setting up libcom-err2:i386 (1.47.0-2ubuntu1) ...
Setting up libkrb5support0:i386 (1.20.1-3ubuntu1) ...
Setting up libk5crypto3:i386 (1.20.1-3ubuntu1) ...
Setting up libkrb5-3:i386 (1.20.1-3ubuntu1) ...
Setting up libgssapi-krb5-2:i386 (1.20.1-3ubuntu1) ...
Setting up libtirpc3:i386 (1.3.3+ds-1) ...
Setting up libnsl2:i386 (1.3.0-2build2) ...
Setting up libnss-nisplus:i386 (1.3-0ubuntu6) ...
Setting up libnss-nis:i386 (3.1-0ubuntu6) ...
Processing triggers for libc-bin (2.38-1ubuntu6) ...
Processing triggers for man-db (2.11.2-3) ...
Scanning processes...
Scanning linux images...

Running kernel seems to be up-to-date.

No services need to be restarted.

No containers need to be restarted.

No user sessions are running outdated binaries.

No VM guests are running outdated hypervisor (qemu) binaries on this host.
```

## 2. Set up Firewall Rules

### Setting Variables

```bash
GAME_PORT_GAME=7777
UFW_PROFILE=satisfactory-firewall
UFW_APPLICATION_PROFILE_FILE="$HOME/$UFW_PROFILE.conf"
UFW_APPLICATION_FOLDER="/etc/ufw/applications.d/"
```

> [!IMPORTANT]
> Expecting no output

### Install and Enable `ufw`

```bash
sudo apt install ufw -y
```

```txt
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
ufw is already the newest version (0.36.2-1).
ufw set to manually installed.
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
```

```bash
# Start and enable service
sudo systemctl start ufw
sudo systemctl enable ufw
```

```txt
Synchronizing state of ufw.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable ufw
```

### Create a `ufw` application profile for the servers ports

```bash
# Create an application firewall.
# See simple-ubuntu-configs/etc/ufw/applications.d
cat << HEREDOC_UFW_APPLICATION > $UFW_APPLICATION_PROFILE_FILE
[$UFW_PROFILE]
title=Satisfactory
description=Satisfactory Dedicated Server Firewall Rules
ports=$GAME_PORT_GAME/tcp|$GAME_PORT_GAME/udp
HEREDOC_UFW_APPLICATION

# copy the file you just created to the ufw applications folder
sudo cp $UFW_APPLICATION_PROFILE_FILE $UFW_APPLICATION_FOLDER

rm $UFW_APPLICATION_PROFILE_FILE
```

> [!IMPORTANT]
> Expecting no output

### Set Firewall Rules

```bash
# Define default rules of the firewall
sudo ufw default allow outgoing     # By default - Allow Outgoing
sudo ufw default deny incoming      # By default - Deny Incoming

# Add exceptions to those rules
sudo ufw allow ssh                  # Allow SSH if this is your management strategy
sudo ufw allow $UFW_PROFILE         # Allow ports listed in the above satisfactory

# Verify rule set are correct
sudo ufw show added
```

```txt
Default outgoing policy changed to 'allow'
(be sure to update your rules accordingly)
Default incoming policy changed to 'deny'
(be sure to update your rules accordingly)
Rules updated
Rules updated (v6)
Rules updated
Rules updated (v6)
Added user rules (see 'ufw status' for running firewall):
ufw allow 22/tcp
ufw allow satisfactory-firewall
```

### Enabling Firewall

```bash
# Turn on the firewall
sudo ufw enable

# Check status of the active rules
sudo ufw status
```

```txt
Command may disrupt existing ssh connections. Proceed with operation (y|n)? y
Firewall is active and enabled on system startup
Status: active

To                         Action      From
--                         ------      ----
22/tcp                     ALLOW       Anywhere
satisfactory-firewall      ALLOW       Anywhere
22/tcp (v6)                ALLOW       Anywhere (v6)
satisfactory-firewall (v6) ALLOW       Anywhere (v6)

```

## 3. Create game user

```bash
GAME_USER="satisfactory"

sudo useradd --system --create-home --shell /bin/false $GAME_USER
```

> [!IMPORTANT]
> Expecting no output

## 4. Create Important Folders

```bash
SATISFACTORY_INSTALL_FOLDER="/var/lib/satisfactory"

sudo mkdir -p $SATISFACTORY_INSTALL_FOLDER
```

> [!IMPORTANT]
> Expecting no output

### Give ownership of the folders to the Game Server's Service Account

```bash
sudo chown -R $GAME_USER:$GAME_USER $SATISFACTORY_INSTALL_FOLDER
```

> [!IMPORTANT]
> Expecting no output

## 5. Test the Install of the as the service account

```bash
sudo --user=$GAME_USER /usr/games/steamcmd +force_install_dir "$SATISFACTORY_INSTALL_FOLDER" +login anonymous +app_update 1690800 validate +quit
```

```txt
Redirecting stderr to '/home/satisfactory/.local/share/Steam/logs/stderr.txt'
ILocalize::AddFile() failed to load file "public/steambootstrapper_english.txt".
[  0%] Checking for available update...
[----] Downloading update (0 of 59782 KB)...
[  0%] Downloading update (0 of 59782 KB)...
[  0%] Downloading update (0 of 59782 KB)...
[  0%] Downloading update (2910 of 59782 KB)...
[  4%] Downloading update (6558 of 59782 KB)...
[ 10%] Downloading update (9162 of 59782 KB)...
[ 15%] Downloading update (11883 of 59782 KB)...
[ 19%] Downloading update (14292 of 59782 KB)...
[ 23%] Downloading update (16715 of 59782 KB)...
[ 27%] Downloading update (19119 of 59782 KB)...
[ 31%] Downloading update (21578 of 59782 KB)...
[ 36%] Downloading update (24295 of 59782 KB)...
[ 40%] Downloading update (26771 of 59782 KB)...
[ 44%] Downloading update (29239 of 59782 KB)...
[ 48%] Downloading update (31695 of 59782 KB)...
[ 53%] Downloading update (34287 of 59782 KB)...
[ 57%] Downloading update (36883 of 59782 KB)...
[ 61%] Downloading update (39355 of 59782 KB)...
[ 65%] Downloading update (41473 of 59782 KB)...
[ 69%] Downloading update (42726 of 59782 KB)...
[ 71%] Downloading update (44086 of 59782 KB)...
[ 73%] Downloading update (45331 of 59782 KB)...
[ 75%] Downloading update (46566 of 59782 KB)...
[ 77%] Downloading update (47921 of 59782 KB)...
[ 80%] Downloading update (49163 of 59782 KB)...
[ 82%] Downloading update (50396 of 59782 KB)...
[ 84%] Downloading update (51587 of 59782 KB)...
[ 86%] Downloading update (52905 of 59782 KB)...
[ 88%] Downloading update (54082 of 59782 KB)...
[ 90%] Downloading update (55274 of 59782 KB)...
[ 92%] Downloading update (56476 of 59782 KB)...
[ 94%] Downloading update (57847 of 59782 KB)...
[ 96%] Downloading update (59100 of 59782 KB)...
[ 98%] Downloading update (59782 of 59782 KB)...
[100%] Download Complete.
[----] Applying update...
[----] Extracting package...
[----] Extracting package...
[----] Extracting package...
[----] Extracting package...
[----] Installing update...
[----] Installing update...
[----] Installing update...
[----] Installing update...
[----] Installing update...
[----] Installing update...
[----] Installing update...
[----] Installing update...
[----] Cleaning up...
[----] Update complete, launching...
tid(2960) burning pthread_key_t == 0 so we never use it
Redirecting stderr to '/home/satisfactory/.local/share/Steam/logs/stderr.txt'
Logging directory: '/home/satisfactory/.local/share/Steam/logs'
[  0%] Checking for available updates...
[----] Verifying installation...
[  0%] Downloading update...
[  0%] Checking for available updates...
[----] Download complete.
[----] Extracting package...
[----] Extracting package...
[----] Extracting package...
[----] Extracting package...
[----] Installing update...
[----] Installing update...
[----] Installing update...
[----] Installing update...
[----] Installing update...
[----] Installing update...
[----] Installing update...
[----] Installing update...
[----] Cleaning up...
[----] Update complete, launching Steamcmd...
tid(2972) burning pthread_key_t == 0 so we never use it
Redirecting stderr to '/home/satisfactory/.local/share/Steam/logs/stderr.txt'
Logging directory: '/home/satisfactory/.local/share/Steam/logs'
[  0%] Checking for available updates...
[----] Verifying installation...
Steam Console Client (c) Valve Corporation - version 1705108307
-- type 'quit' to exit --
Loading Steam API...dlmopen steamservice.so failed: steamservice.so: cannot open shared object file: No such file or directory
OK

Connecting anonymously to Steam Public...OK
Waiting for client config...OK
Waiting for user info...OK
 Update state (0x3) reconfiguring, progress: 0.00 (0 / 0)
 Update state (0x11) preallocating, progress: 42.82 (2208311242 / 5157322194)
 Update state (0x61) downloading, progress: 1.39 (71684140 / 5157322194)
 Update state (0x61) downloading, progress: 7.89 (406672426 / 5157322194)
 Update state (0x61) downloading, progress: 17.57 (906100450 / 5157322194)
 Update state (0x61) downloading, progress: 27.49 (1417849227 / 5157322194)
 Update state (0x61) downloading, progress: 38.36 (1978573668 / 5157322194)
 Update state (0x61) downloading, progress: 48.27 (2489575912 / 5157322194)
 Update state (0x61) downloading, progress: 58.59 (3021737348 / 5157322194)
 Update state (0x61) downloading, progress: 66.49 (3429345713 / 5157322194)
 Update state (0x61) downloading, progress: 74.33 (3833469013 / 5157322194)
 Update state (0x61) downloading, progress: 81.32 (4193988604 / 5157322194)
 Update state (0x61) downloading, progress: 86.66 (4469528542 / 5157322194)
 Update state (0x61) downloading, progress: 93.75 (4835231238 / 5157322194)
 Update state (0x81) verifying update, progress: 1.47 (75878444 / 5157322194)
 Update state (0x81) verifying update, progress: 12.12 (625028641 / 5157322194)
 Update state (0x81) verifying update, progress: 23.56 (1214856046 / 5157322194)
 Update state (0x81) verifying update, progress: 34.84 (1796557083 / 5157322194)
 Update state (0x81) verifying update, progress: 46.40 (2393091841 / 5157322194)
 Update state (0x81) verifying update, progress: 57.78 (2979877893 / 5157322194)
 Update state (0x81) verifying update, progress: 69.28 (3573200242 / 5157322194)
 Update state (0x81) verifying update, progress: 80.86 (4170435356 / 5157322194)
 Update state (0x81) verifying update, progress: 92.37 (4763896689 / 5157322194)
Success! App '1690800' fully installed.
```

## 6. Configure Dedicated Server as a Service

```bash
SYSTEMD_SERVICE_FOLDER="/etc/systemd/system"
GAME_SERVER_SERVICE="satisfactory"
GAME_SERVER_SERVICE_FILE="$GAME_SERVER_SERVICE.service"
```

> [!IMPORTANT]
> Expecting no output

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
ExecStart=$SATISFACTORY_INSTALL_FOLDER/FactoryServer.sh -multihome=0.0.0.0 -Port=$GAME_PORT_GAME

[Install]
WantedBy=multi-user.target
HEREDOC_GAME_SERVER_SERVICE

# copy the file you just created to the systemd folder
sudo cp $GAME_SERVER_SERVICE_FILE $SYSTEMD_SERVICE_FOLDER

rm $GAME_SERVER_SERVICE_FILE
```

> [!IMPORTANT]
> Expecting no output

### Reload services

```bash
sudo systemctl daemon-reload
```

> [!IMPORTANT]
> Expecting no output

### Enable and Start service

```bash
# Enable the service, this starts the service when the system boots up automatically
sudo systemctl enable $GAME_SERVER_SERVICE

# Start the service right now
sudo systemctl start $GAME_SERVER_SERVICE
```

```txt
Created symlink /etc/systemd/system/multi-user.target.wants/satisfactory.service → /etc/systemd/system/satisfactory.service.
```

> [!IMPORTANT]
> This will hang. Specifically the `sudo systemctl start $GAME_SERVER_SERVICE`
>
> This is due to steamcmd connecting to steam, checking for updates, and validating the server files.
>
> This process will be halted after `TimeoutStartSec=180`, and can be adjusted as needed.

### Check the service status

```bash
sudo systemctl status $GAME_SERVER_SERVICE
```

```txt
● satisfactory.service - Satisfactory dedicated server
     Loaded: loaded (/etc/systemd/system/satisfactory.service; enabled; preset: enabled)
     Active: active (running) since Thu 2024-01-25 23:24:49 UTC; 2min 47s ago
    Process: 3361 ExecStartPre=/usr/games/steamcmd +force_install_dir /var/lib/satisfactory +login anonymous +app_update 1690800 validate +quit (code=exited, status=0/SUCCESS)
   Main PID: 3385 (FactoryServer.s)
      Tasks: 40 (limit: 11880)
     Memory: 209.5M
        CPU: 27.327s
     CGroup: /system.slice/satisfactory.service
             ├─3385 /bin/sh /var/lib/satisfactory/FactoryServer.sh -multihome=0.0.0.0 -Port=7777
             └─3392 /var/lib/satisfactory/Engine/Binaries/Linux/UnrealServer-Linux-Shipping FactoryGame -multihome=0.0.0.0 -Port=7777

Jan 25 23:24:53 satisfactory-test FactoryServer.sh[3392]: [2024.01.25-23.24.53:126][  0]LogLoad: Took 0.830103 seconds to LoadMap(/Game/FactoryGame/Map/DedicatedserverEntry)
Jan 25 23:24:53 satisfactory-test FactoryServer.sh[3392]: [2024.01.25-23.24.53:127][  0]LogGame: EOS Metrics, starting service.
Jan 25 23:24:53 satisfactory-test FactoryServer.sh[3392]: [2024.01.25-23.24.53:127][  0]LogGame: Warning: EOS metrics, invalid handle.
Jan 25 23:24:53 satisfactory-test FactoryServer.sh[3392]: [2024.01.25-23.24.53:127][  0]LogGame: Telemetry, starting service.
Jan 25 23:24:53 satisfactory-test FactoryServer.sh[3392]: [2024.01.25-23.24.53:127][  0]LogGame: Warning: Telemetry, no local player found.
Jan 25 23:24:53 satisfactory-test FactoryServer.sh[3392]: [2024.01.25-23.24.53:129][  0]LogGame: Telemetry instance started without a platform.
Jan 25 23:24:53 satisfactory-test FactoryServer.sh[3392]: [2024.01.25-23.24.53:136][  0]LogInit: Display: Engine is initialized. Leaving FEngineLoop::Init()
Jan 25 23:24:53 satisfactory-test FactoryServer.sh[3392]: [2024.01.25-23.24.53:136][  0]LogLoad: (Engine Initialization) Total time: 3.15 seconds
Jan 25 23:24:53 satisfactory-test FactoryServer.sh[3392]: [2024.01.25-23.24.53:170][  0]LogOnlineVoice: OSS: Voice interface disabled by config [OnlineSubsystem].bHasVoiceEnabled
Jan 25 23:24:53 satisfactory-test FactoryServer.sh[3392]: [2024.01.25-23.24.53:839][ 21]LogEOSSDK: LogEOS: SDK Config Platform Update Request Successful, Time: 3.486013
```

## Optional Tweaks

### A. Configure Logging Directory & Logrotate

#### Variables

```bash
SATISFACTORY_LOG_FOLDER="/var/log/satisfactory"
SATISFACTORY_LOGROTATE_CONFIG_FILE="satisfactory.conf"
LOGROTATE_CONFIG_FOLDER="/etc/logrotate.d/"
SATISFACTORY_LOG_STANDARD_OUT="stdout.log"
SATISFACTORY_LOG_STANDARD_ERROR="stderr.log"
```

> [!IMPORTANT]
> Expecting no output

#### Create Logging Directories

```bash
sudo mkdir -p $SATISFACTORY_LOG_FOLDER
sudo chown -R $GAME_USER:$GAME_USER $SATISFACTORY_LOG_FOLDER
```

> [!IMPORTANT]
> Expecting no output

```bash
sudo ls -al $SATISFACTORY_LOG_FOLDER
```

```txt
total 8
drwxr-xr-x 2 satisfactory satisfactory 4096 Jan 25 23:34 .
drwxrwxr-x 9 root         syslog       4096 Jan 25 23:30 ..
-rw-r--r-- 1 satisfactory satisfactory    0 Jan 25 23:34 stderr.log
-rw-r--r-- 1 satisfactory satisfactory    0 Jan 25 23:34 stdout.log
```

#### Create Logrotate Config File

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
sudo cp $SATISFACTORY_LOGROTATE_CONFIG_FILE $LOGROTATE_CONFIG_FOLDER

rm $SATISFACTORY_LOGROTATE_CONFIG_FILE
```

> [!IMPORTANT]
> Expecting no output

#### Dry run the new logrotate config

```bash
# Test the new Logrotate config
logrotate $LOGROTATE_CONFIG_FOLDER$SATISFACTORY_LOGROTATE_CONFIG_FILE --debug
```

```txt
warning: logrotate in debug mode does nothing except printing debug messages!  Consider using verbose mode (-v) instead if this is not what you want.

reading config file /etc/logrotate.d/satisfactory.conf
Reading state from file: /var/lib/logrotate/status
state file /var/lib/logrotate/status does not exist
Allocating hash table for state file, size 64 entries

Handling 1 logs

rotating pattern: /var/log/satisfactory/*.log  after 1 days (no old logs will be kept)
empty log files are not rotated, old logs are removed
considering log /var/log/satisfactory/stderr.log
Creating new state
  Now: 2024-01-25 23:37
  Last rotated at 2024-01-25 23:00
  log does not need rotating (log has already been rotated)
considering log /var/log/satisfactory/stdout.log
Creating new state
  Now: 2024-01-25 23:37
  Last rotated at 2024-01-25 23:00
  log does not need rotating (log has already been rotated)
```

#### Update Systemd Service file with Logging included

```bash
SYSTEMD_SERVICE_FOLDER="/etc/systemd/system"
GAME_SERVER_SERVICE="satisfactory"
GAME_SERVER_SERVICE_FILE="$GAME_SERVER_SERVICE.service"
```

> [!IMPORTANT]
> Expecting no output

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
ExecStart=$SATISFACTORY_INSTALL_FOLDER/FactoryServer.sh -multihome=0.0.0.0 -Port=$GAME_PORT_GAME

[Install]
WantedBy=multi-user.target
HEREDOC_GAME_SERVER_SERVICE

# copy the service unit you just created to the systemd folder
sudo cp $GAME_SERVER_SERVICE_FILE $SYSTEMD_SERVICE_FOLDER

rm $GAME_SERVER_SERVICE_FILE
```

> [!IMPORTANT]
> Expecting no output

### Reload and Restart Services with Logging Added

While we have created the service file we need to now ask systemd to refresh its knowledge of what service files exists.

```bash
sudo systemctl daemon-reload
sudo systemctl restart $GAME_SERVER_SERVICE
sudo systemctl status $GAME_SERVER_SERVICE
```

```txt
● satisfactory.service - Satisfactory dedicated server
     Loaded: loaded (/etc/systemd/system/satisfactory.service; enabled; preset: enabled)
     Active: active (running) since Thu 2024-01-25 23:45:43 UTC; 27ms ago
    Process: 3527 ExecStartPre=/usr/games/steamcmd +force_install_dir /var/lib/satisfactory +login anonymous +app_update 1690800 validate +quit (code=exited, status=0/SUCCESS)
   Main PID: 3556 (FactoryServer.s)
      Tasks: 2 (limit: 11880)
     Memory: 7.7M
        CPU: 19.696s
     CGroup: /system.slice/satisfactory.service
             ├─3556 /bin/sh /var/lib/satisfactory/FactoryServer.sh -multihome=0.0.0.0 -Port=7777
             └─3564 /var/lib/satisfactory/Engine/Binaries/Linux/UnrealServer-Linux-Shipping FactoryGame -multihome=0.0.0.0 -Port=7777

Jan 25 23:45:21 satisfactory-test systemd[1]: Starting satisfactory.service - Satisfactory dedicated server...
Jan 25 23:45:43 satisfactory-test systemd[1]: Started satisfactory.service - Satisfactory dedicated server.
```

> [!IMPORTANT]
> You will no longer see logs in `systemctl status` nor in `journalctl`.
>
> Instead they are pipped to:
>
> - `$SATISFACTORY_LOG_FOLDER/$SATISFACTORY_LOG_STANDARD_OUT`
> - `$SATISFACTORY_LOG_FOLDER/$SATISFACTORY_LOG_STANDARD_ERROR`

### B. Add Server Status Message to the Message Of The Day

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

rm $MOTD_FILE
```

> [!IMPORTANT]
> Expecting no output
