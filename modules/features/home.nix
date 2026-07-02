{ self, inputs, ... }: {
  flake.nixosModules.home = { config, pkgs, lib, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    
    home-manager.useGlobalPkgs = true;
    home-manager.useUserPackages = true;
    home-manager.backupFileExtension = "backup";
    home-manager.users.redue = {
      home.stateVersion = "25.11";
      home.username = "redue";
      home.homeDirectory = "/home/redue";

      home.file.".config/xfce4/helpers.rc".text = ''
        TerminalEmulator=kitty
        FileManager=thunar
      '';

      home.file.".local/share/xfce4/helpers/kitty.desktop".text = ''
        [Desktop Entry]
        Version=1.0
        Icon=kitty
        Type=X-XFCE-Helper
        Name=Kitty
        StartupNotify=false
        X-XFCE-Binaries=kitty;
        X-XFCE-Category=TerminalEmulator
        X-XFCE-Commands=%B;
        X-XFCE-CommandsWithParameter=%B -e %s;
      '';

      home.sessionVariables = {
        EDITOR = "micro";
        VISUAL = "micro";
        TERMINAL = "kitty";
        NIXOS_OZONE_WL = "1";
      };

      home.sessionPath = [
        "$HOME/.local/bin"
        "$HOME/.lmstudio/bin"
      ];

      services.udiskie.enable = true;
      services.udiskie.tray = "always";
      services.udiskie.notify = false;
      services.udiskie.settings = {
        program_options.appindicator = true;
        icon_names.media = [ "udiskie-media" ];
      };

      xdg.configFile."gtk-4.0/gtk.css".force = lib.mkForce true;

      home.activation.removeKvantumConflict = {
        before = [ "linkGeneration" ];
        after = [ "writeBoundary" ];
        data = "rm -rf $HOME/.config/Kvantum/Base16Kvantum";
      };

      home.file.".local/share/icons/hicolor/64x64/apps/udiskie-media.png".source = pkgs.runCommand "udiskie-media.png" {
        nativeBuildInputs = [ pkgs.librsvg ];
      } ''
        rsvg-convert -w 64 -h 64 -f png ${pkgs.papirus-icon-theme}/share/icons/Papirus-Dark/64x64@2x/devices/drive-removable-media.svg > $out
      '';

      programs.bash.enable = true;
      programs.fzf.enable = true;
      programs.starship.enable = true;
      programs.starship.settings = lib.mkForce {
        palette = "noctalia";
        palettes.noctalia = {
          blue = "#b5a895";
          red = "#cf767c";
          green = "#9aa887";
          yellow = "#e5c799";
          cyan = "#96b3aa";
          magenta = "#cbaba0";
          white = "#dcd8cd";
          black = "#231e1a";
        };
      };
		
    home.shellAliases.freedoom = "chocolate-doom -iwad ~/freedoom-0.13.0/freedoom2.wad";

	home.shellAliases.mcp-start = "mcp-proxy --port 3010 -- mcp-server-filesystem /home/redue & mcp-proxy --port 3011 -- mcp-server-git --repository /home/redue/NIX & mcp-proxy --port 3012 -- godot-mcp";
	  
      # Force dark mode preference for apps Stylix can't directly theme
      dconf.settings = {
        "org/gnome/desktop/interface" = {
          color-scheme = "prefer-dark";
        };
      };


      programs.mpv = {
        enable = true;
        scripts = [ pkgs.mpvScripts.mpris ];
      };

      xdg.desktopEntries.spotify = {
        name = "Spotify";
        exec = "spotify --enable-features=UseOzonePlatform --ozone-platform=wayland %U";
        terminal = false;
        type = "Application";
        icon = "spotify-client";
        categories = [ "Audio" "Music" "Player" ];
      };

      gtk.iconTheme = {
        package = pkgs.papirus-icon-theme;
        name = "Papirus-Dark";
      };

      programs.kitty = {
        enable = true;
        settings = {
          confirm_os_window_close = 0;
          shell = "bash --noprofile";
          hide_window_decorations = "yes";

          cursor_trail = 3;
        };
      };

     
      home.packages = with pkgs; [
		
		# Fonts
      	maple-mono.NF

      	# Utils
        gh
        btop
        ffmpeg
        python3
        jq

        # C stuff
        gcc
        valgrind
        gdb

        # Text editors
        micro
        sublime4
        kdePackages.kate

        # Very important
        chocolate-doom

        # Apps
        libreoffice
        spotify
        godot
        blender
        pinta
        qbittorrent
        quickemu
        lmstudio
        antigravity
        ollama
        ungoogled-chromium
        gnome-clocks
        boxbuddy
        drawy

        # Terminal toys (also very important)
        fastfetch
        hyfetch
        asciiquarium
        cowsay
        pipes
        cbonsai
        lolcat
        fortune
        cava

        # MCP
        mcp-server-filesystem
        mcp-server-git
        mcp-proxy
        godot-mcp
      ];

    };
  };
}
