{ config, pkgs, ... }:

{
  home.username = "itsjustmech";
  home.homeDirectory = "/home/itsjustmech";
  home.stateVersion = "25.05";

  # CLI programs and dotfiles
  programs.git.enable = true;
  programs.bash.enable = true;
  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    bat
    eza
    jq
    gh
  ];
}
