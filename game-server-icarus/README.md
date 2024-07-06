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

