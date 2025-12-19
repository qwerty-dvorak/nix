{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  pkgs-unstable = import inputs.nixpkgs-unstable {
    system = pkgs.system;
    # Allow unfree specifically for this import
    config.allowUnfree = true;
  };
  cfg = config.hydenix.system;
in
{
  options.hydenix.system = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable system module";
    };
  };

  config = lib.mkIf cfg.enable {

    environment.systemPackages = with pkgs; [
      parallel # Shell tool for executing jobs in parallel
      jq # Command-line JSON processor
      imagemagick # Image manipulation tools
      resvg # SVG rendering library and tools
      libnotify # Desktop notification library
      envsubst # Environment variable substitution utility
      killall # Process termination utility
      wl-clipboard # Wayland clipboard utilities
      wl-clip-persist # Keep Wayland clipboard even after programs close (avoids crashes)
      gnumake # Build automation tool
      git # distributed version control system
      fzf # command line fuzzy finder
      polkit_gnome # authentication agent for privilege escalation
      dbus # inter-process communication daemon
      upower # power management/battery status daemon
      mesa # OpenGL implementation and GPU drivers
      dconf # configuration storage system
      dconf-editor # dconf editor
      home-manager # user environment manager
      xdg-utils # Collection of XDG desktop integration tools
      desktop-file-utils # for updating desktop database
      hicolor-icon-theme # Base fallback icon theme
      kdePackages.ark # kde file archiver
      cava # audio visualizer
      cliphist # clipboard manager
      wayland # for wayland support
      egl-wayland # for wayland support
      xwayland # for x11 support
      gobject-introspection # for python packages
      trash-cli # cli to manage trash files
      gawk # awk implementation
      coreutils # coreutils implementation
      bash-completion # Add bash-completion package

      hypridle

      go
      # Optional but recommended tools:
      gopls # Go language server
      go-tools # Various Go tools (like gorename, guru)
      gotools # More Go tools (like gomodifytags, impl)
      gotestsum
      delve # Go debugger

      vscode
      dig
      slack
      ripgrep
      appimage-run
      gcc
      graphite-cli
      chromium
      zathura
      nodejs
      pnpm
      ffmpeg
      bun
 
    ];


    environment.variables = {
      NIXOS_OZONE_WL = "1";
      LIBVA_DRIVER_NAME = "iHD";
    };

    programs.hyprland = {
      package = pkgs.hyprland;
      portalPackage = pkgs.xdg-desktop-portal-hyprland;
      enable = true;
      withUWSM = true;
    };

    documentation.man = {
        enable = true;
        generateCaches = true;
    };

    programs.nix-ld.enable = true;
    programs.adb.enable = true;

    programs.appimage = {
      enable = true;
      binfmt = true;
    };


    hardware.bluetooth = {
      enable = true;
      powerOnBoot = true;
      settings = {
        General = {
          Enable = "Source,Sink,Media,Socket";
          Experimental = true;
        };
      };
    };
    
    hardware.graphics = {
      enable = true;
      enable32Bit = true; # Renamed from driSupport32Bit
      extraPackages = with pkgs; [
        intel-media-driver 
        libvdpau-va-gl     
      ];
    };

    services = {
      dbus.enable = true;

      redis.servers."".enable = true;
      upower.enable = true;
      openssh.enable = true;
      libinput.enable = true;
      postgresql = {
          enable = true;
          package = pkgs.postgresql_17_jit;
          dataDir = "/var/lib/postgresql";
          settings = { 
            listen_addresses = lib.mkForce "*";
            max_connections = 100;
            shared_buffers = "128MB";
          };
          authentication = ''
            # Example: allow local connections for user 'postgres' without password
            local all all trust
          '';
      };

      tlp = {
        enable = true;
        settings = {
            # Example: Set max frequency when on AC power.
            # Use a value in kHz from 'cpupower frequency-info'
            # e.g., 2500000 = 2.5GHz
            CPU_SCALING_MAX_FREQ_ON_AC = "2500000";

            # Example: Set max frequency when on battery
            CPU_SCALING_MAX_FREQ_ON_BAT = "1800000";

            # Prevent 'turbo boost' / 'cpu boost'
            CPU_BOOST_ON_AC = 0;
            CPU_BOOST_ON_BAT = 0;
        };
      };
    };    

    programs.dconf.enable = true;
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    programs.zsh.enable = true;
    users.users.hydenix.extraGroups = ["adbusers"];


    # For polkit authentication
    security.polkit.enable = true;
    security.pam.services.swaylock = { };
    security.rtkit.enable = true;
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };

    # For trash-cli to work properly
    services.gvfs.enable = true;

    # For proper XDG desktop integration
    xdg.portal = {
      enable = true;
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
  };

}
