{ config, pkgs, lib, userConfig, ... }:

{
  home.packages = [ pkgs.desktoppr ];

  launchd.agents.set-wallpaper = {
    enable = true;
    config = {
      ProgramArguments = [
        "${pkgs.desktoppr}/bin/desktoppr"
        "${userConfig.homeDirectory}/.config/assets/background1.png"
      ];
      RunAtLoad = true;
    };
  };
}
