# /nix-config

Commands used on primary development system

```bash
# Ran from the folder where flake.nix is located
nix flake update
```

Commands used on the new system

```bash
# This rebuilds from the repo directly
# github:<OWNER>/<REPO>/<BRANCH>?dir=<FOLDER_TO_FLAKE>#<NIXOS_CONFIG_NAME>
# --no-write-lock-file will skip trying to write the lock file back to the git repo. This probably need to be dealt with somehow cause thats probably wrong.
sudo nixos-rebuild switch --flake github:darrickross/homelab/start-nix-flakes?dir=nix-config#itsjustmech@luna --no-write-lock-file
```
