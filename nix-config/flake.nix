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
      # One NixOS config per folder under ./hosts/<host>/default.nix
      nixosConfigurations = lib.genAttrs hostNames (
        host:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [ ./hosts/${host}/default.nix ];
        }
      );

      # One Home-Manger config per user *per host* (cross-product), like user@host
      # Generate a mapping of user's home to "user@host" to figure out what user is associated with it
      homeConfigurations = lib.foldl' (
        acc: host:
        acc
        // lib.genAttrs (map (u: "${u}@${host}") userNames) (
          user:
          home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [ ./homes/${builtins.head (lib.splitString "@" user)}/home.nix ];
          }
        )
      ) { } hostNames;
    };
}
