{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.services.cutefish.artwork;
in
{
  meta = {
    maintainers = with lib.maintainers; [ wineee ];
  };

  ###### interface

  options = {
    services.cutefish.artwork = {
      enable = lib.mkEnableOption "Cutefish icon theme and wallpapers";

      wallpapers.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Whether to install the Cutefish wallpapers.

          They are released under the Unsplash License and therefore marked
          `unfreeRedistributable`, so pulling them in requires
          `nixpkgs.config.allowUnfree = true` or an `allowUnfreePredicate`.
        '';
      };
    };
  };

  ###### implementation

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.cutefish.cutefish-icons ]
      ++ lib.optional cfg.wallpapers.enable pkgs.cutefish.cutefish-wallpapers;

    # The icon theme is found through XDG_DATA_DIRS; the wallpapers live in
    # share/backgrounds and the account presets in share/cutefish, neither of
    # which buildEnv links by default.
    xdg.icons.enable = lib.mkDefault true;
    environment.pathsToLink = [ "/share/backgrounds" "/share/wallpapers" "/share/cutefish" ];
  };
}
