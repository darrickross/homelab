# Satisfactory Game Server

[Icarus dedicated server wiki](https://icarus.fandom.com/wiki/Dedicated_Server)

## Relative Folder Structure

- [*root directory*](../README.md)
  - [/game-server-icarus](./README.md) - ***YOU ARE HERE***
    - [nix-configs/](./nix-configs/README.md)
      - A NixOS configuration file for a Icarus Server

## Networking

| Default port (UDP only) | Port Usage | CLI Override Method | Remappable Port? | Description                                |
|:-----------------------:|------------|---------------------|:----------------:|--------------------------------------------|
|          17777          | Game Port  | `-PORT=12345`       |        Yes       | Port used for game data transmission.      |
|          27015          | Query Port | `-QueryPort=54321`  |        Yes       | Port used for querying server status/info. |

## Command Line Arguments

| Option                              | Example                                                       | Description                                                                                                            |
|-------------------------------------|---------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------|
| `-SteamServerName="NAME"`           | `-SteamServerName="My Server"`                                | Sets the session name in the server browser, limited to 64 characters                                                  |
| `-UserDir=PATH`                     | `-UserDir=`                                                   | Allows changing the base directory that Saved/ and other files are created in. Path can be relative or absolute.       |
| `-saveddirsuffix=SUFFIX`            | `-saveddirsuffix=saturn_save`                                 | Appends the `Saved/` directory with the provided suffix. Creates a folder like `saturn_save/`.                         |
| `-LOG=PATH`                         | `-LOG=./MyLog.log`                                            | Log path relative to the `Saved/Logs/` folder. Moves the log up to the Saved folder and renames it `MyLog.log`.        |
| `-ABSLOG=PATH`                      | `-ABSLOG=/var/log/MyLog.log`                                  | Absolute log path. May require elevated permissions depending on path.                                                 |
| `-PORT=PORT`                        | `-PORT=12345`                                                 | Port used for game data transmission.                                                                                  |
| `-QueryPort=PORT`                   | `-QueryPort=54321`                                            | Port used for querying server status/info.                                                                             |
| `-MULTIHOME=IP_ADDRESS`             | `-MULTIHOME=192.168.1.4`                                      | Set the specific IP address which the server will listen on.                                                           |
| `-ResumeProspect`                   | `-ResumeProspect`                                             | Automatically tries to resume the last prospect on start up.                                                           |
| `-LoadProspect=PROSPECT_NAME`       | `-LoadProspect=MyProspect`                                    | Loads the prospect by name from Saved/PlayerData/DedicatedServer/Prospects/ on start up.                               |
| `-CreateProspect="PROSPECT_STRING"` | `-CreateProspect="Tier1_Forest_Recon_0 1 false ExampleName1"` | Creates and launches a prospect on start up using the passed in parameters. See below for examples of Prospect Strings |

### Prospect String Examples

The following is an example of a Prospect String for creating a prospect.

```none
ProspectType Difficulty Hardcore SaveName
```

#### Prospect Type

[Icarus Prospect Types](https://icarus.fandom.com/wiki/Category:Prospects#Olympus_Prospect_List_Comparison)

[Third party list of Prospect Names](https://github.com/RocketWerkz/IcarusDedicatedServer/wiki/Prospect-Names)

#### Difficulty

The following is a table of Difficulty values and their corresponding meaning. See the following for what each difficulty means for game settings:
[Icarus Wiki - Prospects - Difficulties](https://icarus.fandom.com/wiki/Category:Prospects#Difficulties)

| Difficulty Value | Meaning                                                                     |
|------------------|-----------------------------------------------------------------------------|
| `1`              | [Easy](https://icarus.fandom.com/wiki/Category:Prospects#Easy)              |
| `2`              | [Normal](https://icarus.fandom.com/wiki/Category:Prospects#Medium_(Normal)) |
| `3`              | [Hard](https://icarus.fandom.com/wiki/Category:Prospects#Hard)              |
| `4`              | Extreme - Unknown                                                           |

## Troubleshooting errors
