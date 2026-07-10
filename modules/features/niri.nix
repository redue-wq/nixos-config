{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };
  };

  perSystem = { pkgs, lib, self', ... }: {
    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      settings = {
        spawn-at-startup = [
          "/etc/profiles/per-user/redue/bin/noctalia"
          "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent"
        ];

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";

        input = {
          keyboard.xkb.layout = "it";
        };

        cursor = {
          xcursor-theme = "Bibata-Modern-Ice";
          xcursor-size = 24;
        };

        layer-rules = [
          {
            matches = [{ namespace = "^noctalia-wallpaper*"; }];
            place-within-backdrop = true;
          }
        ];

        layout = {
          gaps = 5;
          background-color = "transparent";
          focus-ring = {
            width = 2;
            active-color = "#e0a84a";
            inactive-color = "#313244";
          };
        };

        overview = {
          workspace-shadow.off = {};
        };

        window-rules = [
          {
            background-effect.blur = true;
            draw-border-with-background = false;
            geometry-corner-radius = 16;
            clip-to-geometry = true;
          }
          { matches = [{ app-id = "org.gnome.clocks"; }]; opacity = 0.7; }
          {
            matches = [{
              app-id = "steam";
              title = "^notificationtoasts_\\d+_desktop$";
            }];

            
            
            default-floating-position = _: {
              props = {
                x = 10;
                y = 10;
                relative-to = "bottom-right";
              };
            };
          }
        ];

        binds = {
          "Mod+F1".show-hotkey-overlay = {};

          # ── Media & hardware ──────────────────────────────────────────
          "XF86AudioMute".spawn-sh        = "noctalia msg volume-mute";
          "XF86AudioLowerVolume".spawn-sh = "noctalia msg volume-down 1";
          "XF86AudioRaiseVolume".spawn-sh = "noctalia msg volume-up 1";
          "XF86MonBrightnessDown".spawn-sh = "brightnessctl set 1%-";
          "XF86MonBrightnessUp".spawn-sh   = "brightnessctl set 1%+";

          # ── Apps ──────────────────────────────────────────────────────
          "Mod+Return".spawn-sh = "kitty";
          "Mod+B".spawn-sh      = "firefox";
          "Mod+E".spawn-sh      = "thunar";

          # ── Noctalia UI ───────────────────────────────────────────────
          "Mod+S".spawn-sh = "noctalia msg panel-toggle launcher";

          # ── Session ───────────────────────────────────────────────────
          "Mod+Ctrl+L".spawn-sh = "noctalia msg session lock";
          "Mod+Ctrl+S".spawn-sh = "noctalia msg session lock-and-suspend";
          "Mod+Shift+Q".quit    = {};

          # ── Window management ─────────────────────────────────────────
          "Mod+Q".close-window               = {};
          "Mod+F".fullscreen-window          = {};
          "Mod+Shift+F".toggle-window-floating = {};
          "Mod+C".center-column              = {};
          "Mod+W".maximize-column            = {};
          "Mod+A".toggle-overview            = {};
          "Mod+N".consume-or-expel-window-left  = {};
          "Mod+M".consume-or-expel-window-right = {};
          "Mod+O".toggle-window-rule-opacity = {};

          # ── Focus (vim-style) ─────────────────────────────────────────
          "Mod+H".focus-column-left  = {};
          "Mod+L".focus-column-right = {};
          "Mod+U".focus-window-down  = {};
          "Mod+I".focus-window-up    = {};

          # ── Move windows ──────────────────────────────────────────────
          "Mod+Shift+H".move-column-left  = {};
          "Mod+Shift+L".move-column-right = {};
          "Mod+Shift+U".move-window-down  = {};
          "Mod+Shift+I".move-window-up    = {};

          # ── Workspaces (sequential) ───────────────────────────────────
          "Mod+J".focus-workspace-down               = {};
          "Mod+K".focus-workspace-up                 = {};
          "Mod+Shift+J".move-window-to-workspace-down = {};
          "Mod+Shift+K".move-window-to-workspace-up   = {};

          # ── Workspaces (by index) ─────────────────────────────────────
          "Mod+1".focus-workspace = 1;
          "Mod+2".focus-workspace = 2;
          "Mod+3".focus-workspace = 3;
          "Mod+4".focus-workspace = 4;
          "Mod+5".focus-workspace = 5;
          "Mod+6".focus-workspace = 6;
          "Mod+7".focus-workspace = 7;
          "Mod+8".focus-workspace = 8;
          "Mod+9".focus-workspace = 9;
          "Mod+Shift+1".move-window-to-workspace = 1;
          "Mod+Shift+2".move-window-to-workspace = 2;
          "Mod+Shift+3".move-window-to-workspace = 3;
          "Mod+Shift+4".move-window-to-workspace = 4;
          "Mod+Shift+5".move-window-to-workspace = 5;
          "Mod+Shift+6".move-window-to-workspace = 6;
          "Mod+Shift+7".move-window-to-workspace = 7;
          "Mod+Shift+8".move-window-to-workspace = 8;
          "Mod+Shift+9".move-window-to-workspace = 9;

          # ── Resize ────────────────────────────────────────────────────
          "Mod+Minus".set-column-width       = "-10%";
          "Mod+Plus".set-column-width        = "+10%";
          "Mod+Ctrl+Minus".set-window-height = "-10%";
          "Mod+Ctrl+Plus".set-window-height  = "+10%";

          # ── Screenshots ───────────────────────────────────────────────
          "Print".screenshot        = {};
          "Ctrl+Print".screenshot-screen = {};
          "Alt+Print".screenshot-window = {};
        };
      };
    };
  };
}
