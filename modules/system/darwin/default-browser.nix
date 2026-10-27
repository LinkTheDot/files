{ config, pkgs, lib, ... }:

{
  environment.systemPackages = [ pkgs.defaultbrowser ];

  system.activationScripts.postActivation.text = ''
    echo "setting Firefox as default browser..." >&2
    ${pkgs.defaultbrowser}/bin/defaultbrowser firefox || true
  '';
}
