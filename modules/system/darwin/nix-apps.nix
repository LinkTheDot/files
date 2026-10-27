{ config, pkgs, lib, userConfig ? { }, ... }:

let
  username = userConfig.username or "work-user";
  homeDir = userConfig.homeDirectory or "/Users/${username}";
in
{
  system.activationScripts.applications.text = lib.mkForce ''
    echo "setting up /Applications/Nix Apps..." >&2
    rm -rf "/Applications/Nix Apps"
    mkdir -p "/Applications/Nix Apps"

    link_apps_from() {
      local src_dir="$1"
      [ -d "$src_dir" ] || return 0
      find -L "$src_dir" -maxdepth 1 -name "*.app" | while read -r app; do
        local target
        if [ -L "$app" ]; then
          target=$(readlink "$app")
        else
          target="$app"
        fi
        local name
        name=$(basename "$app")
        ${pkgs.mkalias}/bin/mkalias "$target" "/Applications/Nix Apps/$name"
      done
    }

    link_apps_from "${config.system.build.applications}/Applications"
    link_apps_from "${homeDir}/Applications/Home Manager Apps"
  '';
}
