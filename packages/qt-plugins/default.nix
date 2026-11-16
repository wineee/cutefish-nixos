{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  qt6Packages,
  librsvg,
  wayland,
  wayland-scanner,
  wayland-protocols,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-qt-plugins";
  version = "1.0-unstable-2026-11-01";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "qt-plugins";
    rev = "8d79992d37764b6e487b7e7a16c83eab6f4b69ee";
    hash = "sha256-lwbqnDmSk4VsUugBbkBqS5pJW2mSwbhsgpcdwOg4oG0=";
  };

  patches = [
    # Qt 6.11 removed QWindowSystemInterface::handleThemeChange(QWindow*).
    ./qt611-handle-theme-change.patch
    # Install the plugins into our own output instead of the directory
    # qtpaths6 reports, which lives inside qtbase and is read-only.
    ./qtplugins-install-to-output.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    wayland-scanner
  ];

  buildInputs = [
    qt6Packages.qtbase
    qt6Packages.qttools
    librsvg
    wayland
    wayland-protocols
  ];

  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DCUTEFISH_QT_PLUGIN_DIR=${placeholder "out"}/${qt6Packages.qtbase.qtPluginPrefix}"
  ];

  # Qt plugins only, nothing to wrap.
  dontWrapQtApps = true;

  meta = {
    description = "Qt integration plugins for the Cutefish desktop";
    homepage = "https://github.com/cutefishos/qt-plugins";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
