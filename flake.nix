{
  description = "Forketyfork's Darwin System Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # packages installed for all users
      environment.systemPackages =
        [ pkgs.curl
          pkgs.vim
          pkgs.k9s
          pkgs.kind
          pkgs.exercism
          pkgs.jq
          pkgs.ffmpeg
          pkgs.fdupes
          pkgs.git
          pkgs.go
          pkgs.golangci-lint
          pkgs.kubernetes-helm
          pkgs.awscli
          pkgs.minikube
          pkgs.gradle
          pkgs.direnv
          pkgs.imagemagick
          pkgs.yq
          pkgs.yt-dlp
          pkgs.kotlin
          pkgs.scala
          pkgs.dive
          pkgs.qpdf
          pkgs.gh
          pkgs.pre-commit
          pkgs.helix
          pkgs.emacs
          pkgs.saml2aws
        ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true;  # default shell on catalina
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # authorize sudo with Touch ID instead of the password
      security.pam.enableSudoTouchIdAuth = true;

      system.defaults = {
        dock.mru-spaces = false;
        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "clmv";
        loginwindow.LoginwindowText = "JetBrains";
        screencapture.location = "~/Library/Mobile Documents/com~apple~CloudDocs/Screenshots";
        screensaver.askForPasswordDelay = 10;
      };

      nix.extraOptions = ''
        extra-platforms = x86_64-darwin aarch64-darwin
      '';

    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."work" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."work".pkgs;

 };
}