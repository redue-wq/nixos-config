{ self, inputs, ... }: {
  flake.nixosModules.noctalia = { pkgs, ... }: {
  home-manager.users.redue = {
    imports = [ inputs.noctalia.homeModules.default ];
    programs.noctalia = {
      enable = true;
      settings.theme.templates = {
        enable_community_templates = true;
        community_ids = [ "pywalfox-beta4" ];
      };
    };
  };
};
}
