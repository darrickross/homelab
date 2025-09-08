{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }:
    let
      lib = nixpkgs.lib;
      pkgs = nixpkgs.legacyPackages.x86_64-linux;

      # Here I want to pull a list of all hosts and homes (users) that are defined in my configs
      # I specifically will only have directories for each host/home, so we filter for just directories
      hostNames = builtins.attrNames (
        lib.filterAttrs (_: v: v == "directory") (builtins.readDir ./hosts)
      );
      userNames = builtins.attrNames (
        lib.filterAttrs (_: v: v == "directory") (builtins.readDir ./homes)
      );
    in
    {
      # One NixOS config per user@host where user is the primaryUser
      nixosConfigurations = lib.foldl' (
        acc: host:
        let
          metaPath = ./. + "/hosts/${host}/meta.nix";
          hostMeta =
            if builtins.pathExists metaPath then
              import metaPath
            else
              {
                isGui = false;
                autoLogin = false;
              };
        in
        acc
        // lib.genAttrs (map (u: "${u}@${host}") userNames) (
          userAtHost:
          let
            user = builtins.head (lib.splitString "@" userAtHost);
          in
          nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
              inherit hostMeta;
              primaryUser = user;
              inherit lib;
            };
            modules = [ ./hosts/${host}/default.nix ];
          }
        )
      ) { } hostNames;

      # One Home-Manger config per user *per host* (cross-product), like user@host
      # Generate a mapping of user's home to "user@host" to figure out what user is associated with it
      homeConfigurations = lib.foldl' (
        acc: host:
        let
          metaPath = ./. + "/hosts/${host}/meta.nix";
          hostMeta = if builtins.pathExists metaPath then import metaPath else { isGui = false; };
          guiEnable = hostMeta.isGui or false;
        in
        acc
        // lib.genAttrs (map (u: "${u}@${host}") userNames) (
          userAtHost:
          let
            user = builtins.head (lib.splitString "@" userAtHost);
          in
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              ./homes/${user}/home.nix
              # Include the user's GUI module only when true
              (lib.mkIf guiEnable ./homes/${user}/gui.nix)
            ];
            extraSpecialArgs = { inherit hostMeta; };
          }
        )
      ) { } hostNames;
    };
}
