# Satisfactory Game Server

[Satisfactory dedicated server wiki](https://satisfactory.fandom.com/wiki/Dedicated_servers)

## Local Folder Structure

- [*root directory*](../README.md)
- [/game-server-satisfactory](./README.md)
  - [game-configs/](./game-configs/README.md)
    - Common Game Config Files and Settings
  - [nix-configs/](./nix-configs/README.md)
    - A NixOS configuration file for a Satisfactory Server
  - [simple-ubuntu-configs/](./simple-ubuntu-configs/README.md)
    - A simple Ubuntu config and help document to install a Satisfactory server on Ubuntu

## Networking

| Default port (UDP only) |  Port Usage |                                                                                                                                    Description                                                                                                                                   |
|:-----------------------:|:-----------:|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
| 15777                   | Query Port  | This is the port that you need to enter in the game when you first connect to a dedicated server. **This port can be redirected freely.**                                                                                                                                            |
| 15000                   | Beacon Port | This port is automatically incremented if multiple instances of the server are launched and the default is in use already. As of Update 6, **this port can be redirected freely.**                                                                                                   |
| 7777                    | Game Port   | **This port can be redirected freely(**) using the -Port parameter upon server startup, e. g. "-Port=10000" to change the game port to UDP port 10000. At present, if the default port is in use, the next higher one will be checked until a free port is found, and it will be used. |

## Command Line Arguments

|             Option               |          Example         |                                                                                                                      Description                                                                                                                      |
|:--------------------------------:|:------------------------:|:-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------:|
| `-multihome=`*IP_ADDRESS* | `-⁠multihome=192.168.1.4` | Bind the server process to a specific IP address rather than all available interfaces |
| `-ServerQueryPort=`*PORT* | `-⁠ServerQueryPort=15000` | Override the Query Port the server uses. This is the port specified in the Server Manager in the client UI to establish a server connection. This can be set freely. The default port is UDP/15777.|
| `-BeaconPort=`*PORT*      | `-⁠BeaconPort=15001`      | Override the Beacon Port the server uses. As of Update 6, this port can be set freely. The default port is UDP/15000. If this port is already in use, the server will step up to the next port until an available one is found.|
| `-Port=`*PORT*            | `-Port=15002`            | Override the Game Port the server uses. This is the primary port used to communicate game telemetry with the client. The default port is UDP/7777. If it is already in use, the server will step up to the next port until an available one is found. |
| `-log`                    | `-log`                   | Forces the server to display logs in a window (on Windows) or in the active terminal (on Linux). This option is implicit by default when launching on Linux.                                                                                          |
| `-unattended`             | `-unattended`            | Makes it such that the Dedicated Server will not present any dialogs which might otherwise interrupt the server from running if not attended to. This option is implicit by default when launching on Linux,                                          |
| `-DisablePacketRouting`   | `-DisablePacketRouting`  | Startup argument for disabling the packet router (Automatically disabled with multihome)                                                                                                                                                              |

## Troubleshooting errors

### UNetConnection::Tick: Connection TIMED OUT. Closing Connection

Full Error Message

```log
UNetConnection::Tick: Connection TIMED OUT. Closing
connection.. Elapsed: 30.00, Real: 30.00, Good: 30.00,
DriverTime: 36.46, Threshold: 30.00, [UNetConnection]
RemoteAddr: XXX.XXX.XXX.XXX:XXXXX, Name:
IpConnection_2147470173, Driver: GameNetDriver
NetDriverEOSBase_2147470174, IsServer: NO, PC:
BP_PlayerController_C_214769524, UniqueId: Steam:1
(76571198415751586)
```

Update `INSTALL_DIRECTORY/FactoryGame/Saved/Config/LinuxServer/Game.ini` with the content:

```ini
[/Script/Engine.GameSession]
InitialConnectTimeout=180.0
ConnectionTimeout=120.0
```

This increases the allowed connection time for slower connections.

[Website Solution A](https://shockbyte.com/billing/knowledgebase/654/How-To-Fix-Connection-Timed-Out-In-Satisfactory.html)
