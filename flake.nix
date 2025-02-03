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
        shfmt # shell parser, formatter and interpreter
        rustup # the rust programming language
        virtualenv # tool to create isolated Python environments
        inkscape-with-extensions # vector graphics editor
        vsce # VS Code extension publication
        ocaml # OCaml compiler
        opam # OCaml package manager
        nvd # Nix package version diff tool
        newsboat # RSS reader
        ollama # create, run and share LLMs
        maven # java build tool
        realvnc-vnc-viewer # VNC viewer
        websocat # sending websocket requests
        cmake # to build whisper
        zulu21 # JDK 21
        gawk # GNU version of awk
        hexfiend # Hex editor
        zed-editor # Zed editor
        vlc-bin # VLC media player
        fzf # command-line fuzzy finder
        yazi # terminal file manager
        lnav # multifile log navigator
        hyperfine
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
        "karabiner-elements"
        "ghostty" # Ghostty terminal emulator; not yet packaged for Darwin, see https://github.com/ghostty-org/ghostty/discussions/2824
      ];

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      nix.package = pkgs.nix;

      # if karabiner-elements doesn't work after the initial installation,
      # try to disable/enable all related Login Items in the settings
      # commented out until https://github.com/LnL7/nix-darwin/issues/1041 is solved
      # services.karabiner-elements.enable = true;

      fonts.packages = [
        pkgs.nerd-fonts.iosevka
      ];

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Create /etc/zshrc that loads the nix-darwin environment.
      programs.zsh = {
        enable = true; # default shell on catalina
        variables = {
          JAVA_HOME = "${pkgs.zulu17.home}/zulu-17.jdk/Contents/Home";
          EDITOR = "vim";
        };
        enableFastSyntaxHighlighting = true;
        enableFzfCompletion = true;
        enableFzfGit = true;
        enableFzfHistory = true;
        shellInit = ''
          function y() {
              local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
              yazi "$@" --cwd-file="$tmp"
              if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
                  builtin cd -- "$cwd"
              fi
              rm -f -- "$tmp"
          }
        '';
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

      # git configuration
      system.activationScripts.extraUserActivation.text = ''
        set -e
        echo "Setting global git configuration"
        git config --global core.autocrlf input
        git config --global merge.tool vimdiff
        git config --global init.defaultbranch main
        git config --global core.editor vim
        git config --global gpg.format ssh
        git config --global commit.gpgsign true
        git config --global gpg.ssh.program /Applications/1Password.app/Contents/MacOS/op-ssh-sign

        # setting up the default toolchain for rust
        rustup default stable
      '';

      system.defaults = {
        dock = {
          mru-spaces = false;
          # hot action for bottom left corner: disabled
          wvous-bl-corner = 1;
          # hot action for bottom right corner: disabled
          wvous-br-corner = 1;
          # hot action for top left corner: disable screen saver
          wvous-tl-corner = 6;
          # hot action for top right corner: disabled
          wvous-tr-corner = 1;
        };

        trackpad = {
          # enable three-finger drag
          TrackpadThreeFingerDrag = true;
        };

        finder = {
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          FXPreferredViewStyle = "clmv";
          QuitMenuItem = true;
        };

        loginwindow.LoginwindowText = "JetBrains";
        screencapture.location = "~/Library/Mobile Documents/com~apple~CloudDocs/Screenshots";
        screensaver.askForPasswordDelay = 10;

        NSGlobalDomain = {
          # Dark mode
          AppleInterfaceStyle = "Dark";
          # Disable automatic spelling correction
          NSAutomaticSpellingCorrectionEnabled = false;
          # Disable automatic capitalization
          NSAutomaticCapitalizationEnabled = false;
          # Disable automatic quote substitution
          NSAutomaticQuoteSubstitutionEnabled = false;
          # Use F1, F2, etc. keys as standard function keys
          "com.apple.keyboard.fnState" = true;
          # tap to click
          "com.apple.mouse.tapBehavior" = 1;
          # drag windows on Ctrl+Cmd+Click
          NSWindowShouldDragOnGesture = true;
        };
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
        git-config-forketyfork = "git config --local user.signingkey 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJoq4nD/EcvDY30Xx4hfQz864TMR3MTNnVvOPYQYJezf' && git config --local user.name Forketyfork && git config --local user.email forketyfork@icloud.com";
      };

      launchd.user.agents = {
        ollama = {
          command = "${pkgs.ollama}/bin/ollama serve";
          serviceConfig = {
            Label = "ollama";
            EnvironmentVariables = {
              OLLAMA_HOST = "127.0.0.1:11434";
              OLLAMA_KV_CACHE_TYPE = "q4_0";
              OLLAMA_FLASH_ATTENTION = "1";
            };
            StandardOutPath = "/tmp/ollama.out.log";
            StandardErrorPath = "/tmp/ollama.err.log";
            RunAtLoad = true;
            KeepAlive = true;
          };
        };
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
