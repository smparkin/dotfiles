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
            pkgs.mkalias
            pkgs.openjdk17
            pkgs.openjdk21
            pkgs.appcleaner
            pkgs.discord
            pkgs.docker
            pkgs.iina
            pkgs.iterm2
            pkgs.obsidian
            pkgs.ollama
            pkgs.openscad
            pkgs.prismlauncher
            pkgs.qbittorrent
            pkgs.rectangle
            pkgs.vscode
        ];
      
      homebrew = {
        enable = true;
        casks = [
          "alfred"
          "balenaetcher"
          "bambu-studio"
          "daisydisk"
          "firefox"
          "font-sf-mono"
          "istat-menus"
          "protonvpn"
          "raspberry-pi-imager"
          "scroll-reverser"
          "sf-symbols"
          "steam"
        ];
        brews = [
          "asitop"
          "bpytop"
          "mas"
        ];
        masApps = {
          "Broadcasts" = 1469995354;
          "Callsheet" = 1672356376;
          "Developer" = 640199958;
          "Infuse" = 1136220934;
          "Noir" = 1592917505;
          "Overcast" = 888422857;
          "SponsorBlock" = 1573461917;
          "TestFlight" = 899247664;
          "TheUnarchiver" = 425424353;
          "Unread" = 1363637349;
          "WiFiMan" = 1385561119;
          "Wipr" = 1320666476;
          "Xcode" = 497799835;
          "WireGuard" = 1451685025;
        };
        onActivation.cleanup = "zap";
      };

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      system.activationScripts.applications.text = let
        env = pkgs.buildEnv {
          name = "system-applications";
          paths = config.environment.systemPackages;
          pathsToLink = "/Applications";
        };
      in
        pkgs.lib.mkForce ''
          # Set up applications.
          echo "setting up /Applications..." >&2
          rm -rf /Applications/Nix\ Apps
          mkdir -p /Applications/Nix\ Apps
          find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + |
          while read -r src; do
            app_name=$(basename "$src")
            echo "copying $src" >&2
            ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
          done
        '';

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
