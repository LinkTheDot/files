{ config, pkgs, lib, userConfig ? { }, ... }:

let
  username = userConfig.username or "work-user";
in
{
  imports = [
    ./dnsmasq.nix
    ./nix-apps.nix
    ./default-browser.nix
  ];

  # Disable nix-darwin's management of Nix since we're using Determinate Nix
  # Determinate Nix handles the nix daemon and configuration itself
  nix.enable = false;

  # Enable Touch ID for sudo  
  security.pam.services.sudo_local.touchIdAuth = true;

  system.defaults = {
    controlcenter.BatteryShowPercentage = true;
    NSGlobalDomain.KeyRepeat = 2;
    NSGlobalDomain.InitialKeyRepeat = 15;
    NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
    dock.autohide = true;
    dock.orientation = "left";
    dock.magnification = false;
    dock.show-recents = false;
    dock.tilesize = 32;
    dock.mru-spaces = false;
    finder.AppleShowAllExtensions = true;
    finder.AppleShowAllFiles = true;
    finder.CreateDesktop = false;
    finder.FXPreferredViewStyle = "icnv";
    screencapture.location = "~/Pictures/screenshots";
    LaunchServices.LSQuarantine = false;
    ".GlobalPreferences"."com.apple.mouse.scaling" = 1.3;
    CustomUserPreferences.".GlobalPreferences"."AppleMenuBarVisibleInFullscreen" = false;
    CustomUserPreferences.".GlobalPreferences"."AutoHideMenuBarInFullScreen" = true;
    CustomUserPreferences.".GlobalPreferences"."com.apple.mouse.linear" = true;
    CustomUserPreferences.".GlobalPreferences"."com.apple.scrollwheel.scaling" = -1.0;
    CustomUserPreferences."com.apple.timezone.auto".Active = true;
    CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys."64" = {
      enabled = true;
      value.parameters = [ 32 49 262144 ];
      value.type = "standard";
    };
    CustomUserPreferences."com.apple.symbolichotkeys".AppleSymbolicHotKeys."30" = {
      enabled = true;
      value.parameters = [ 115 1 1179648 ];
      value.type = "standard";
    };
  };

  # Display sleep after 15 minutes (security requirement)
  power.sleep.display = 15;
  power.sleep.computer = 15;

  # Create /etc/zshrc that loads the nix-darwin environment
  programs.zsh.enable = true;

  # Platform specific
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  system.stateVersion = 6;

  # IMPORTANT: This requires the actual macOS username to be set in users.local.nix
  # The username must match an existing user on the system
  system.primaryUser = username;

  # User configuration - define the user for nix-darwin
  users.users.${username} = {
    name = username;
    home = userConfig.homeDirectory or "/Users/${username}";
  };
}
