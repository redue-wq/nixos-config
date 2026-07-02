{ self, inputs, ... }: {
  flake.nixosModules.noctalia = { pkgs, ... }: {
  home-manager.users.redue = {
    imports = [ inputs.noctalia.homeModules.default ];
    programs.noctalia.enable = true;
  };
};
}
