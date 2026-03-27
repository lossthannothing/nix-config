# modules/den.nix
#
# Den framework initialization
# - Loads den flakeModule
# - Registers "loss" namespace
# - Sets up __findFile for angle-bracket imports (<loss/...>, <den/...>)
{inputs, den, ...}: {
  _module.args.__findFile = den.lib.__findFile;
  imports = [
    inputs.den.flakeModule
    (inputs.den.namespace "loss" true)
  ];
}
