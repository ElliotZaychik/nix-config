{ config, pkgs, ... }: {

	nix.settings.experimental-features = [ "nix-command" "flakes"];
  # Font configuration
  fonts = {
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font Mono" ];
      };
    };
  };

  imports = [ ./hardware-configuration.nix ];

  # Allow insecure packages
  nixpkgs.config.permittedInsecurePackages = [
    "freeimage-unstable-2021-11-01"
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  
  # Filesystem support
  boot.supportedFilesystems = [ "ntfs" ];

  # Networking
  networking.hostName = "nixos";
  networking.networkmanager.enable = true;

  # Time and locale
  time.timeZone = "Asia/Tehran";
  i18n.defaultLocale = "en_US.UTF-8";

  # Desktop Environment (KDE Plasma)
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb.layout = "us";

  # Printing
  services.printing.enable = true;

  # Audio
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Flatpak configuration
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];

  # Fix for Flatpak apps in desktop menus
  environment.sessionVariables = {
    XDG_DATA_DIRS = [
      "/var/lib/flatpak/exports/share"
      "/home/elliot/.local/share/flatpak/exports/share"
    ];
  };

  # User configuration
  users.users.elliot = {
    isNormalUser = true;
    description = "elliot";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  # System packages
  environment.systemPackages = with pkgs; [
    python313 jdk21 git neovim unzip starship geany wget 
    cloudflare-warp lunar-client nekoray telegram-desktop appimage-run discord vscode lutris wine picom alacritty 
    ntfs3g fastfetch firefox btop cava kew
    flatpak  # Add flatpak to system packages
  ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Cloudflare WARP service
  systemd.services.warp-svc = {
    enable = true;
    description = "Cloudflare WARP Service";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.cloudflare-warp}/bin/warp-svc";
      Restart = "on-failure";
    };
  };

  # Auto-connect WARP on startup
  systemd.services.warp-autoconnect = {
    enable = true;
    description = "Auto-connect to Cloudflare WARP";
    after = [ "warp-svc.service" ];
    wantedBy = [ "multi-user.target" ];
    script = ''
      sleep 5
      ${pkgs.cloudflare-warp}/bin/warp-cli connect
    '';
  };

  # Automatic mounting of New Volume (NTFS)
  fileSystems."/mnt/NewVolume" = {
    device = "/dev/disk/by-uuid/0C8A94B68A949DB0";
    fsType = "ntfs-3g";
    options = [
      "rw"
      "uid=1000"    # Your user ID (elliot)
      "gid=100"     # users group
      "nofail"      # Prevent boot failure if drive missing
      "umask=022"   # Permissions: 755 (rwxr-xr-x)
    ];
  };

  system.stateVersion = "24.11";
}
