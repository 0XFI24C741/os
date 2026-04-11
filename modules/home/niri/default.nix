# Live-editable niri config managed via home-manager.
#
# home-manager creates ~/.config/niri/config.kdl as an out-of-store symlink
# pointing at the live file in the repo checkout. This means:
#   - edits to modules/home/niri/config.kdl apply instantly (niri watches its config)
#   - the file is git-tracked and participates in normal commit flow
#   - no nixos-rebuild is needed for config tweaks after the initial switch
#
# Caveat: the symlink target hardcodes ~/Developer/os. Moving the checkout
# breaks the symlink until the next rebuild regenerates it.
{ config, ... }:
{
  xdg.configFile."niri/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/Developer/os/modules/home/niri/config.kdl";
}
