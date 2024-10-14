# Satisfactory Game Server

[Satisfactory dedicated server wiki](https://satisfactory.fandom.com/wiki/Dedicated_servers)

## 0 - Relative Folder Structure

- [*root directory*](../README.md)
  - [/game-server-satisfactory](./README.md) <------------ ***YOU ARE HERE***
    - [nix-configs/](./nix-configs/README.md)
      - A NixOS configuration file for a Satisfactory Server
    - [simple-ubuntu-configs/](./simple-ubuntu-configs/README.md)
      - A simple Ubuntu config and help document to install a Satisfactory server on Ubuntu

## 1 - Table of Contents

- [0 - Relative Folder Structure](#0---relative-folder-structure)
- [1 - Table of Contents](#1---table-of-contents)
- [2 - Networking](#2---networking)
- [3 - Command Line Arguments](#3---command-line-arguments)
- [4 - Troubleshooting errors](#4---troubleshooting-errors)
  - [4.1 - UNetConnection::Tick: Connection TIMED OUT. Closing Connection](#41---unetconnectiontick-connection-timed-out-closing-connection)
    - [4.1.a - Common Error Situation](#41a---common-error-situation)
    - [4.1.b - Example Log Messages](#41b---example-log-messages)
    - [4.1.c - Solution](#41c---solution)
    - [4.1.d - Example Links discussing fix](#41d---example-links-discussing-fix)
  - [4.2 - Server Crashes when creating a new Session](#42---server-crashes-when-creating-a-new-session)
    - [4.2.a - Common Error Situation](#42a---common-error-situation)
    - [4.2.b - Example Log Messages](#42b---example-log-messages)
    - [4.2.c - Solution](#42c---solution)
    - [4.2.d - Example Links discussing fix](#42d---example-links-discussing-fix)
    - [4.2.e - Theory Why](#42e---theory-why)

## 2 - Networking

| Default port |  Protocol | Port Usage | Description                                                                                                                                                                                                                                                                        |
|:------------:|:---------:|:----------:|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
|     7777     | TCP & UDP |  Game Port | **This port can be redirected freely(**) using the -Port parameter upon server startup, e. g. "-Port=10000" to change the game port to port 10000. At present, if the default port is in use, the next higher one will be checked until a free port is found, and it will be used. |

## 3 - Command Line Arguments

|           Option          |          Example         | Description                                                                                                                                                                                                                                                         |
|:-------------------------:|:------------------------:|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `-multihome=`*IP_ADDRESS* | `-⁠multihome=192.168.1.4` | Bind the server process to a specific IP address rather than all available interfaces                                                                                                                                                                               |
| `-Port=`*PORT*            | `-Port=15002`            | Override the Game Port the server uses. This is the primary port the client uses to communicate with the server. The default port is both UDP/7777 and TCP/7777. If it is already in use, the server will step up to the next port until an available one is found. |
| `-log`                    | `-log`                   | Forces the server to display logs in a window (on Windows) or in the active terminal (on Linux). This option is implicit by default when launching on Linux.                                                                                                        |
| `-unattended`             | `-unattended`            | Makes it such that the Dedicated Server will not present any dialogs which might otherwise interrupt the server from running if not attended to. This option is implicit by default when launching on Linux,                                                        |
| `-DisablePacketRouting`   | `-DisablePacketRouting`  | Startup argument for disabling the packet router (Automatically disabled with multihome)                                                                                                                                                                            |

## 4 - Troubleshooting errors

### 4.1 - UNetConnection::Tick: Connection TIMED OUT. Closing Connection

#### 4.1.a - Common Error Situation

Players are unable to connect to the server, and receive the error `UNetConnection::Tick: Connection TIMED OUT. Closing Connection`.

#### 4.1.b - Example Log Messages

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

#### 4.1.c - Solution

Update `INSTALL_DIRECTORY/FactoryGame/Saved/Config/LinuxServer/Game.ini` with the content:

```ini
[/Script/Engine.GameSession]
InitialConnectTimeout=180.0
ConnectionTimeout=120.0
```

This increases the allowed connection time for slower connections.

#### 4.1.d - Example Links discussing fix

- <https://shockbyte.com/billing/knowledgebase/654/How-To-Fix-Connection-Timed-Out-In-Satisfactory.html>

### 4.2 - Server Crashes when creating a new Session

#### 4.2.a - Common Error Situation

If the server crashes when creating a new session (or possibly when loading a session...) check that the VM is using a CPU type which matches the hypervisor's CPU. If you are using `generic` or in proxmox's case `Default (kvm64)` the server will likely fail to create a session.

#### 4.2.b - Example Log Messages

```log
[2024.10.13-18.12.21:056][308]LogWorldPartition: Display: WorldPartition initialize took 1 ms
[2024.10.13-18.12.21:207][308]LogLoad: Game class is 'BP_GameMode_C'
[2024.10.13-18.12.21:210][308]LogReplicationGraph: Display: SetActorDiscoveryBudget set to 20 kBps (5333 bits per network tick).
[2024.10.13-18.12.21:210][308]LogNetCore: DDoS detection status: detection enabled: 0 analytics enabled: 0
[2024.10.13-18.12.21:210][308]LogNet: Created socket for bind address: 0.0.0.0:0
[2024.10.13-18.12.21:210][308]PacketHandlerLog: Loaded PacketHandler component: DTLSHandlerComponent ()
[2024.10.13-18.12.21:210][308]PacketHandlerLog: Loaded PacketHandler component: Engine.EngineHandlerComponentFactory (

Signal 6 caught.
Malloc Size=262146 LargeMemoryPoolOffset=262162

StatelessConnectHandlerComponent)
[2024.10.13-18.12.21:210][308]PacketHandlerLog: Loaded PacketHandler component: FactoryDedicatedServer.> QueryHandlerComponentFactory (DSQueryHandlerComponent)
[2024.10.13-18.12.21:210][308]LogNet: GameNetDriver FGDSIpNetDriver_2147482188 IpNetDriver listening on port 0
CommonUnixCrashHandler: Signal=6
[2024.10.13-18.12.21:261][308]LogCore: === Critical error: ===
Unhandled Exception: SIGABRT: abort() called

[2024.10.13-18.12.21:261][308]LogCore: Fatal error!
```

#### 4.2.c - Solution

Review the Virtual Machine CPU settings. Ensure the CPU type given to the Virtual Machine matches the host's CPU architecture. Most Hypervisors will include a automatic setting to match the host.

> [!NOTE]
> For example Proxmox has a settings `Host`, which selects the same architecture as the host system.

#### 4.2.d - Example Links discussing fix

- <https://questions.satisfactorygame.com/post/655d96f4d0053b102f18eff1>
- <https://questions.satisfactorygame.com/post/65541b42d0053b102f18dc60>

#### 4.2.e - Theory Why

When selecting which CPU type the VM will use, the host is selecting which instruction set the VM will have available. Meaning if the satisfactory server code expected a standard AMD x64 instruction set and was met instead with an instruction set missing some instructions the program would crash, or might abort early due to an assertion check.
