{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.hydenix.hm.hyprland;
in
{
  config = lib.mkIf (cfg.enable && cfg.windowrules.enable) {
    home.file = {
      ".config/hypr/windowrules.conf" =
        if cfg.windowrules.overrideConfig != null then
          {
            text = cfg.windowrules.overrideConfig;
            force = true;
          }
        else
          {
            # FIX: We read the file, then patch the specific syntax error before writing it
            text = ''
              ${
                let
                  upstreamConfig = lib.readFile "${pkgs.hyde}/Configs/.config/hypr/windowrules.conf";
                  patchedConfig = builtins.replaceStrings
                    ["windowrule = float,initialtitle:^(Open File)$"]
                    ["windowrule = float,initialTitle:^(Open File)$"]
                    upstreamConfig;
                in
                  patchedConfig
              }
              ${cfg.windowrules.extraConfig}
            '';
            force = true;
          };
    };
  };
}
