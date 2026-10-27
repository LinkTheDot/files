{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    coreutils
    curl
    fish
    vim
  ];

  homebrew.brews = [
    "autoconf"
    "botan@2"
    "gettext"
    "gmp"
    "jpeg-turbo"
    "libnghttp2"
    "libyaml"
    "openssl@3"
    "pkgconf"
    "readline"
    "zstd"
  ];

  # botan@2 is keg-only in Homebrew; the linker and botan-sys need these
  # paths in every build context, not just fish shells.
  environment.variables = {
    LIBRARY_PATH = "/opt/homebrew/opt/botan@2/lib";
    PKG_CONFIG_PATH = "/opt/homebrew/opt/botan@2/lib/pkgconfig";
  };

  # Reaches GUI/IDE launched builds, which never source the shell rc.
  launchd.user.envVariables = {
    LIBRARY_PATH = "/opt/homebrew/opt/botan@2/lib";
    PKG_CONFIG_PATH = "/opt/homebrew/opt/botan@2/lib/pkgconfig";
  };
}
