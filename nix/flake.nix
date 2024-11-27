{
  description = "smparkin Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, config, ... }: {

      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment.systemPackages =
        [
            pkgs.fastfetch
            pkgs.coreutils
            pkgs.openjdk17
            pkgs.openjdk21
        ];

      homebrew = {
        enable = true;
        casks = [
          "appcleaner"
          "balenaetcher"
          "bambu-studio"
          "daisydisk"
          "discord"
          "docker"
          "firefox"
          "font-sf-mono"
          "iina"
          "istat-menus"
          "iterm2"
          "obsidian"
          "ollama"
          "prismlauncher"
          "protonvpn"
          "qbittorrent"
          "raspberry-pi-imager"
          "raycast"
          "rectangle"
          "scroll-reverser"
          "sf-symbols"
          "steam"
          "visual-studio-code"
        ];
        brews = [
          "mas"
        ];
        masApps = {
          "Broadcasts" = 1469995354;
          "Callsheet" = 1672356376;
          "Developer" = 640199958;
          "Flighty" = 1358823008;
          "Infuse" = 1136220934;
          "Noir" = 1592917505;
          "Numbers" = 409203825;
          "Overcast" = 888422857;
          "Pages" = 409201541;
          "SponsorBlock" = 1573461917;
          "TestFlight" = 899247664;
          "TheUnarchiver" = 425424353;
          "Unread" = 1363637349;
          "WiFiMan" = 1385561119;
          "Wipr" = 1320666476;
          "WireGuard" = 1451685025;
          "Xcode" = 497799835;
        };
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      system.defaults = {
        dock.autohide = true;
        trackpad.Clicking = true;
        trackpad.TrackpadThreeFingerDrag = true;
      };

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "smparkin";
            autoMigrate = true;
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."macbook".pkgs;
  };
}
