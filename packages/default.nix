{ pkgs }:
# Cutefish package set.
#
# A plain attribute set fixed over itself instead of a lib.makeScope: nothing
# here needs scope helpers, and the toolkit does not use Qt/DTK (it draws with
# Skia on GLES).
#
# Upstream (github.com/cutefishos) publishes no tags; every package is pinned
# to a commit. toolkit/framework/compositor/core speak private Wayland
# protocols and must be bumped together. See docs/survey.md.
pkgs.lib.fix (self: {
  cutefish-wallpapers = pkgs.callPackage ./wallpapers { };
  cutefish-icons = pkgs.callPackage ./icons { };

  # Pinned Skia; cutefish-toolkit links it as static libraries.
  cutefish-skia = pkgs.callPackage ./skia { };

  cutefish-toolkit = pkgs.callPackage ./toolkit {
    inherit (self) cutefish-skia;
  };

  cutefish-framework = pkgs.callPackage ./framework {
    inherit (self) cutefish-toolkit;
  };

  cutefish-compositor = pkgs.callPackage ./compositor {
    inherit (self) cutefish-toolkit cutefish-framework;
  };

  # Applications; every one of them does find_package(CutefishToolkit).
  cutefish-text-editor = pkgs.callPackage ./text-editor {
    inherit (self) cutefish-toolkit;
  };
  cutefish-terminal = pkgs.callPackage ./terminal {
    inherit (self) cutefish-toolkit;
  };
  cutefish-filemanager = pkgs.callPackage ./filemanager {
    inherit (self) cutefish-toolkit cutefish-framework;
  };
  cutefish-settings = pkgs.callPackage ./settings {
    inherit (self) cutefish-toolkit cutefish-framework;
  };
  cutefish-calendar = pkgs.callPackage ./calendar {
    inherit (self) cutefish-toolkit;
  };
  cutefish-video-player = pkgs.callPackage ./video-player {
    inherit (self) cutefish-toolkit;
  };
  cutefish-system-monitor = pkgs.callPackage ./system-monitor {
    inherit (self) cutefish-toolkit;
  };
  cutefish-calculator = pkgs.callPackage ./calculator {
    inherit (self) cutefish-toolkit;
  };
  # Images and PDFs: needs the framework's files and pdf libraries.
  cutefish-preview = pkgs.callPackage ./preview {
    inherit (self) cutefish-toolkit cutefish-framework;
  };
  xdg-desktop-portal-cutefish = pkgs.callPackage ./portal {
    inherit (self) cutefish-toolkit;
  };

  # Session and background services. Runs the compositor, so it depends on it.
  cutefish-core = pkgs.callPackage ./core {
    inherit (self) cutefish-toolkit cutefish-framework cutefish-compositor;
  };

  # Qt/Papyrus integration for third-party Qt applications.
  cutefish-qt-plugins = pkgs.callPackage ./qt-plugins { };

  # Display manager: the login screen is the compositor itself.
  cutefish-dm = pkgs.callPackage ./dm {
    inherit (self) cutefish-toolkit cutefish-compositor;
  };

  # Everything upstream ships as a desktop application is packaged above. What
  # is left out: cutefish-installer (NixOS has its own), cutefish-webkit (a
  # WebKit fork, too large to be worth it), cutefish-computer-use (Rust, an MCP
  # server for AI control, optional).
})
