{
  description = "Forketyfork's Darwin System Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs @ {
    self,
    nix-darwin,
    nixpkgs,
  }: let
    configuration = {pkgs, ...}: {
      # packages installed for all users
      environment.systemPackages = with pkgs; [
        curl
        wget
        vim
        k9s
        kind
        exercism
        jq
        ffmpeg
        fdupes
        git
        go
        golangci-lint
        kubernetes-helm
        awscli
        minikube
        gradle
        direnv
        imagemagick
        yq
        yt-dlp
        kotlin
        scala
        dive
        qpdf
        gh
        pre-commit
        helix
        emacs
        saml2aws
        gping
        yarn
        nodejs_20
        ripgrep
        gnumake
        alejandra
        neovim
        zulu17
        shellcheck # Shell script analysis tool
        hadolint # Dockerfile linter
        ghostscript # converter for PDF, PostScript, etc.
        pipenv # Python dependency management
        kubectl # Kubernetes command line interface
        kubelogin-oidc # oidc plugin for kubectl
        nasm # assembler
        hexfiend # hex editor
      ];

      # homebrew-installed packages
      homebrew.enable = true;
      homebrew.brews = [
        "djview4"
        "coder"
      ];
      homebrew.casks = [
        "google-cloud-sdk"
        "jordanbaird-ice" # menu bar manager
      ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      nix.package = pkgs.nix;

      # if karabiner-elements doesn't work after the initial installation,
      # try to disable/enable all related Login Items in the settings
      services.karabiner-elements.enable = true;

      fonts.fontDir.enable = true;
      fonts.fonts = with pkgs; [
        nerdfonts
      ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh.enable = true; # default shell on catalina
      programs.zsh.variables = {
        JAVA_HOME = "${pkgs.zulu17.home}/zulu-17.jdk/Contents/Home";
      };

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";

      # Allow "unfree" packages, e.g. Terraform
      nixpkgs.config.allowUnfree = true;

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

      environment.variables = {
        JAVA_HOME = "${pkgs.zulu17.home}/zulu-17.jdk/Contents/Home";
        DOCKER_CLI_HINTS = "false"; # disable stupid "what's next" hints
      };

      environment.shellAliases = {
        fdupes-books = "fdupes -rnd ~/Downloads/books ~/Library/Mobile\\ Documents/com\\~apple\\~CloudDocs/Library";
      };
    };
  in {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#simple
    darwinConfigurations."work" = nix-darwin.lib.darwinSystem {
      modules = [configuration];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."work".pkgs;
  };
}
