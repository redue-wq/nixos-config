{ self, inputs, ... }:
{
  # Umbriel — Wayland compositor on wlroots + umbrielfx (hard fork of SceneFX)
  # Docs: https://docs.noctalia.dev/umbriel/
  # Config reference: https://docs.noctalia.dev/umbriel/configuration/
  # Example: https://github.com/noctalia-dev/umbriel/blob/main/examples/config.toml
  #
  # Usage: add `self.nixosModules.umbriel` to `imports` in
  # `modules/hosts/my-machine/configuration.nix` next to `self.nixosModules.niri`.
  # Then pick Umbriel vs Niri on the greeter (F3). `session.default = "niri"` in
  # noctalia-greeter will keep Niri default until you change it.
  #
  # Mirrors `niri.nix` structure where possible, but Umbriel uses TOML via
  # `programs.umbriel.settings` (Home Manager) instead of wrapper-modules.
  # See also: nix/home-module.nix (settings -> $XDG_CONFIG_HOME/umbriel/config.toml)
  # and nix/nixos-module.nix (system package + portal + sessionPackages).

  flake.nixosModules.umbriel =
    {
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        inputs.umbriel.nixosModules.default
      ];

      # System: install Umbriel + portal + session .desktop
      # https://raw.githubusercontent.com/noctalia-dev/umbriel/main/nix/nixos-module.nix
      # withDefaultPackage (via inputs.umbriel.nixosModules.default) already sets
      # package = inputs.umbriel.packages.<system>.default as mkDefault, so just enable:
      programs.umbriel.enable = true;
      # Keep portal for screen sharing (OBS, browsers). Set to null to disable:
      # programs.umbriel.portalPackage = null;

      # User: declarative TOML config (live-reloaded, validated at build)
      # https://docs.noctalia.dev/umbriel/configuration/
      # https://github.com/noctalia-dev/umbriel/blob/main/examples/config.toml
      home-manager.users.redue = {
        imports = [ inputs.umbriel.homeModules.default ];

        programs.umbriel = {
          enable = true;
          # validateConfig = true by default -> `umbriel validate -c` at build

          settings = {
            # Include Noctalia's generated palette — https://docs.noctalia.dev/umbriel/configuration/#include
            # Noctalia writes ~/.config/umbriel/noctalia.toml; this makes Umbriel load it (main file still wins)
            include = {
              files = [ "noctalia.toml" ];
            };

            # General — https://docs.noctalia.dev/umbriel/configuration/#general
            general = {
              autostart = [
                "noctalia"
                "${pkgs.lxqt.lxqt-policykit}/bin/lxqt-policykit-agent"
              ];
              mod_key = "Super"; # Mod in keybinds; Alt when nested (same as niri cursor mod)
              xwayland = true; # needs xwayland-satellite on PATH (niri uses satellite too)
              show_cheatsheet = true;
              focus_on_activate = false;
            };

            # Workspaces — https://docs.noctalia.dev/umbriel/workspaces/
            workspaces = {
              back_and_forth = false;
              empty_above = false;
            };

            # Per-workspace layout overrides — https://docs.noctalia.dev/umbriel/workspaces/#workspace-rules
            # https://github.com/noctalia-dev/umbriel/blob/main/examples/config.toml#L118
            # Third workspace uses dwindle, others stay scrolling (global layout.mode)
            workspace = [
              {
                name = "3";
                layout.mode = "dwindle";
              }
            ];

            # Layout — https://docs.noctalia.dev/umbriel/layout/
            # Mirrors niri: gaps 5, scrolling default (niri is scrolling-only)
            layout = {
              mode = "scrolling"; # scrolling | dwindle | master — per-workspace override via [[workspace]]
              gap = 5; # niri gaps 5
              width_presets = [
                0.333
                0.5
                0.667
              ];
              struts = {
                left = 0;
                right = 0;
                top = 0;
                bottom = 0;
              };
              scrolling = {
                default_width_fraction = 0.5;
                center_underfull_strip = true;
                center_focused = false;
                expand_single_column = true;
              };
              master = {
                position = "left";
                default_width_fraction = 0.55;
                new_on_top = true;
              };
              # dwindle.preserve_split = false; # uncomment to keep split direction
            };

            # Appearance — https://docs.noctalia.dev/umbriel/appearance/
            # Mirrors niri: corner_radius 16, blur, focus-ring #e0a84a / #313244
            appearance = {
              prefer_no_csd = true;
              border_width = 2;
              outer_border_width = 0;
              corner_radius = 16; # niri geometry-corner-radius 16
              drag_opacity = 0.75;
              blur = {
                enabled = true;
                optimized = true;
                passes = 3;
                radius = 3;
                noise = 0.02;
                brightness = 0.9;
                contrast = 0.9;
                saturation = 1.1;
              };
              shadow = {
                enabled = true;
                softness = 10;
                offset_x = 2;
                offset_y = 2;
              };
            };

            # Colors — https://docs.noctalia.dev/umbriel/appearance/#colors
            colors = {
              shadow = "#0000007F"; # was appearance.shadow.color
              # border colors — niri focus-ring active/inactive
              # border.focused = "#e0a84a";
              # border.unfocused = "#313244";
            };

            # Colors — https://docs.noctalia.dev/umbriel/appearance/
            # Leave unset to follow Noctalia sync; example shown:
            # colors = {
            #   background = "#141419FF";
            #   accent_primary = "#e0a84a";
            # };

            # Animation — https://docs.noctalia.dev/umbriel/animation/
            animation = {
              enabled = true;
              duration_ms = 250;
              curve = "easeout";
              windows_in = {
                enabled = true;
                duration_ms = 150;
                curve = "easeout";
                style = "popin";
                scale = 0.85;
              };
              windows_out = {
                enabled = true;
                duration_ms = 150;
                curve = "easeout";
                style = "fade";
              };
              windows_move = {
                enabled = true;
                duration_ms = 250;
                curve = "snappy";
              };
              workspaces = {
                enabled = true;
                duration_ms = 250;
                curve = "easeout";
              };
              overview = {
                enabled = true;
                duration_ms = 250;
                curve = "easeout";
              };
            };

            # Overview — https://docs.noctalia.dev/umbriel/workspaces-overview/
            overview = {
              zoom = 0.5;
              # background_blur = true;
            };

            # Input — https://docs.noctalia.dev/umbriel/input/
            # Mirrors niri: keyboard it, cursor Bibata-Modern-Ice 24, Xwayland Satellite
            input = {
              keyboard = {
                layout = "it"; # niri input.keyboard.xkb.layout it
                variant = "";
                options = "";
                repeat_rate = 25;
                repeat_delay = 600;
                track_layout = "global";
                numlock_toggle = true;
              };
              touchpad = {
                tap = true;
              };
              mouse = {
                sensitivity = 0.0;
                scroll_wheel_step = 60;
              };
              tablet = {
                enabled = true;
              };
              cursor = {
                theme = "Bibata-Modern-Ice";
                size = 24;
                hardware_cursor = true;
                follows_focus = false;
                hide_when_typing = false;
                hide_timeout_ms = 0;
              };
              focus = {
                follows_mouse = false;
                # follows_mouse_max_scroll = 0.5;
              };
            };

            # Outputs — https://docs.noctalia.dev/umbriel/outputs/
            # Uncomment to pin per-connector. Example from docs:
            # output = {
            #   "DP-1" = {
            #     mode = "2560x1440@144";
            #     scale = 1.25;
            #     position = [0 0];
            #   };
            # };

            # Keybinds — https://docs.noctalia.dev/umbriel/keybinds/
            # and actions: https://docs.noctalia.dev/umbriel/actions/
            # Mirrors your niri.nix binds where mapping exists; Umbriel actions differ.
            keybinds = {
              # ── Apps (niri Mod+Return/B/E) ──────────────────────────
              "Mod+Return" = "spawn:kitty"; # niri Mod+Return kitty
              "Mod+B" = "spawn:firefox"; # niri Mod+B firefox
              "Mod+E" = "spawn:thunar"; # niri Mod+E thunar

              # ── Noctalia UI (niri Mod+S) ────────────────────────────
              "Mod+S" = "spawn:noctalia msg panel-toggle launcher"; # niri Mod+S launcher

              # ── Session (niri Mod+Ctrl+L/S) ─────────────────────────
              "Mod+Ctrl+L" = "spawn:noctalia msg session lock";
              "Mod+Ctrl+S" = "spawn:noctalia msg session lock-and-suspend";

              # ── Window management ───────────────────────────────────
              "Mod+Q" = "window-close"; # niri Mod+Q close-window (Umbriel default is Mod+Shift+Q)
              "Mod+Shift+Q" = "window-close"; # keep niri Mod+Shift+Q = quit alias
              "Mod+F" = "window-toggle-fullscreen"; # niri Mod+F fullscreen-window
              "Mod+Shift+F" = "window-toggle-floating"; # niri Mod+Shift+F toggle-window-floating
              "Mod+T" = "window-toggle-floating"; # example default
              "Mod+P" = "window-toggle-pinned";
              "Mod+N" = "window-consume-left"; # niri Mod+N
              "Mod+M" = "window-consume-right"; # niri Mod+M
              "Mod+Shift+N" = "window-consume-or-expel-left";
              "Mod+Shift+M" = "window-consume-or-expel-right"; # niri expel — restored (was overwritten)
              "Mod+D" = "window-toggle-maximize-to-edges"; # maximize to edges — free key, as you asked
              "Mod+C" = "column-center";
              "Mod+O" = "overview-toggle"; # niri Mod+A overview; Umbriel overview is Mod+O

              # ── Media & hardware (niri XF86*) ──────────────────────
              "XF86AudioMute" = "spawn:noctalia msg volume-mute";
              "XF86AudioLowerVolume" = "spawn:noctalia msg volume-down 1";
              "XF86AudioRaiseVolume" = "spawn:noctalia msg volume-up 1";
              "XF86MonBrightnessDown" = "spawn:brightnessctl set 1%-";
              "XF86MonBrightnessUp" = "spawn:brightnessctl set 1%+";

              # ── Focus vim-style (niri Mod+H/L/U/I) — fixed to match niri: J=down, K=up, U=down, I=up
              # Umbriel: window-focus-left/right/up/down + column moves
              "Mod+H" = "window-focus-left";
              "Mod+L" = "window-focus-right";
              "Mod+U" = "window-focus-down"; # niri U = down (was inverted)
              "Mod+I" = "window-focus-up"; # niri I = up
              "Mod+Shift+H" = "column-move-left";
              "Mod+Shift+L" = "column-move-right";
              "Mod+Shift+U" = "window-move-down"; # niri Shift+U = down
              "Mod+Shift+I" = "window-move-up"; # niri Shift+I = up

              # ── Workspaces (niri J/K sequential) — fixed: J=down/next, K=up/previous
              "Mod+J" = "workspace-next"; # niri J = down
              "Mod+K" = "workspace-previous"; # niri K = up
              "Mod+Shift+J" = "window-move-to-workspace-next";
              "Mod+Shift+K" = "window-move-to-workspace-previous";

              # ── Workspaces by index (niri 1..9) ────────────────────
              "Mod+1" = "workspace-switch:1";
              "Mod+2" = "workspace-switch:2";
              "Mod+3" = "workspace-switch:3";
              "Mod+4" = "workspace-switch:4";
              "Mod+5" = "workspace-switch:5";
              "Mod+6" = "workspace-switch:6";
              "Mod+7" = "workspace-switch:7";
              "Mod+8" = "workspace-switch:8";
              "Mod+9" = "workspace-switch:9";
              "Mod+Shift+1" = "window-move-to-workspace:1";
              "Mod+Shift+2" = "window-move-to-workspace:2";
              "Mod+Shift+3" = "window-move-to-workspace:3";
              "Mod+Shift+4" = "window-move-to-workspace:4";
              "Mod+Shift+5" = "window-move-to-workspace:5";
              "Mod+Shift+6" = "window-move-to-workspace:6";
              "Mod+Shift+7" = "window-move-to-workspace:7";
              "Mod+Shift+8" = "window-move-to-workspace:8";
              "Mod+Shift+9" = "window-move-to-workspace:9";

              # ── Resize (niri Mod+Minus/Plus) ───────────────────────
              "Mod+Minus" = "window-modify-width:-0.1";
              "Mod+Plus" = "window-modify-width:+0.1";
              "Mod+Ctrl+Minus" = "window-modify-height:-0.1";
              "Mod+Ctrl+Plus" = "window-modify-height:+0.1";
              "Mod+R" = "window-cycle-width";

              # ── Scrolling strip — Umbriel auto-reveals on focus, no extra keys needed
              # Touchpad 3-finger swipe + Mod+drag still work natively
              # Uncomment if you ever want explicit strip pan:
              # "Mod+Alt+H" = "layout-scroll-left";
              # "Mod+Alt+L" = "layout-scroll-right";
              # "Mod+MouseMiddle" = "layout-scroll-drag";

              # ── Scratchpad & utility ───────────────────────────────
              "Mod+Space" = "scratchpad-toggle"; # show/hide scratchpad (per-output)
              "Mod+Shift+Space" = "window-move-to-scratchpad"; # send focused window to scratchpad
              "Mod+G" = "window-restore-from-scratchpad"; # easy one-handed — as you asked
              "Mod+Ctrl+Space" = "window-restore-from-scratchpad";
              "Mod+Alt+Space" = "window-restore-from-scratchpad"; # restore from scratchpad to workspace
              "Mod+Tab" = "scratchpad-focus-next"; # cycle visible scratchpad windows
              "Mod+F1" = "cheatsheet-toggle"; # niri show-hotkey-overlay

              # ── Screenshots — Umbriel has no built-in screenshot actions (unlike niri)
              # Use grim+slurp over wlr-screencopy + satty (already in your systemPackages)
              # Mirrors niri: Print region, Ctrl+Print screen, Alt+Print output
              "Print" = "spawn:sh -c 'grim -g \"$(slurp)\" - | satty --filename - --copy-command wl-copy'";
              "Ctrl+Print" = "spawn:sh -c 'grim - | satty --filename - --copy-command wl-copy'";
              "Alt+Print" = "spawn:sh -c 'grim -g \"$(slurp -o)\" - | satty --filename - --copy-command wl-copy'";
            };

            # Window rules — https://docs.noctalia.dev/umbriel/window-rules/
            # Mirrors niri: blur + rounded clip + Noctalia floating
            window_rule = [
              {
                blur = true;
                blur_optimized = true;
              }
              {
                match.app_id = "^dev\\.noctalia\\.Noctalia$";
                default_floating = true;
                default_size = [
                  1020
                  900
                ];
              }
              {
                match.app_id = "^dev\\.noctalia\\.UmbrielSharePicker$";
                default_floating = true;
                default_size = [
                  800
                  600
                ];
              }
              {
                match.app_id = "^org\\.gnome\\.clocks$";
                opacity = 0.7;
              }
            ];

            # Layer rules — https://docs.noctalia.dev/umbriel/layer-rules/
            layer_rule = [
              {
                match.namespace = "^noctalia-(bar-[^\"]+|notification|dock|panel|attached-panel|osd)$";
                blur = false; # test: make panels opaque like Niri (was true + opacity 0.65 which did nothing)
                blur_ignore_alpha = 0.5;
                blur_optimized = false;
              }
              {
                # niri: layer-rules matches namespace ^noctalia-wallpaper* -> place-within-backdrop
                # Umbriel equivalent: match wallpaper backdrop
                match.namespace = "^noctalia-wallpaper.*";
                blur = false;
              }
            ];

            # Security context — https://docs.noctalia.dev/umbriel/security/
            # security_context_rule = [
            #   {
            #     match.sandbox_engine = "org\\.flatpak";
            #     match.app_id = "org\\.example\\.ClipboardManager";
            #     allow_globals = ["ext_data_control_manager_v1"];
            #   }
            # ];
          };
        };

        # Fix Noctalia 5.0.0's outdated Umbriel template (writes appearance.border_* etc.)
        # Umbriel 0.1.0 moved them to colors.border.* / colors.* / colors.overview.*
        # Without this, `umbriel validate` warns and borders fall back to defaults.
        home.file.".local/bin/fix-umbriel-noctalia" = {
          executable = true;
          text = ''
            #!/usr/bin/env python3
            import pathlib, re, sys
            p = pathlib.Path.home() / ".config/umbriel/noctalia.toml"
            if not p.exists():
                sys.exit(0)
            t = p.read_text()
            if "border_focused" not in t and "background_tint" not in t:
                sys.exit(0)  # already fixed
            # Extract and rebuild with new keys
            def g(k):
                m = re.search(rf'^{re.escape(k)}\s*=\s*"([^"]+)"', t, re.MULTILINE)
                return m.group(1) if m else None
            cols = {}
            for k in ["background","text_primary","text_muted","accent_primary","accent_secondary","warning","error"]:
                v = g(k)
                if v: cols[k] = v
            border = {}
            for old, new in [("border_focused","focused"),("border_unfocused","unfocused"),("scratchpad_border_focused","scratchpad_focused"),("scratchpad_border_unfocused","scratchpad_unfocused"),("outer_border_color","outer")]:
                v = g(old)
                if v: border[new] = v
            insert = g("insert_hint_color")
            backdrop = g("backdrop_color")
            bg = g("background_tint")
            out = []
            out.append("[colors]")
            for k,v in cols.items(): out.append(f'{k} = "{v}"')
            if insert: out.append(f'insert_hint = "{insert}"')
            if backdrop: out.append(f'backdrop = "{backdrop}"')
            out.append("")
            out.append("[colors.border]")
            for k,v in border.items(): out.append(f'{k} = "{v}"')
            if bg:
                out.append("")
                out.append("[colors.overview]")
                out.append(f'background_tint = "{bg}"')
            p.write_text("\n".join(out) + "\n")
          '';
        };

        home.activation.fixNoctaliaUmbriel = {
          after = [ "writeBoundary" ];
          before = [ "linkGeneration" ];
          data = "$HOME/.local/bin/fix-umbriel-noctalia || true";
        };

        systemd.user.services.fix-umbriel-noctalia = {
          Unit.Description = "Fix Noctalia Umbriel template for Umbriel 0.1.0";
          Service = {
            Type = "oneshot";
            ExecStart = "%h/.local/bin/fix-umbriel-noctalia";
          };
        };
        systemd.user.paths.fix-umbriel-noctalia = {
          Unit.Description = "Watch Noctalia Umbriel palette for outdated keys";
          Path.PathChanged = "%h/.config/umbriel/noctalia.toml";
          Install.WantedBy = [ "default.target" ];
          Unit.After = [ "graphical-session.target" ];
        };
      };
    };
}
