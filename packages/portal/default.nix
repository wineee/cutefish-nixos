{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gettext,
  systemd,
  pipewire,
  wayland,
  wayland-scanner,
  wayland-protocols,
  libdrm,
  libgbm,
  cutefish-toolkit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xdg-desktop-portal-cutefish";
  version = "1.0-unstable-2026-11-04";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "xdg-desktop-portal-cutefish";
    rev = "19765bcce46880e36a8cfb6b7bdcc6bd09076b59";
    hash = "sha256-y6I2vEuWIeZ5onV+LknRBheVdgKGje/ODMSyFeR/J14=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    wayland-scanner
    # cutefish_add_translations() looks msgfmt up with find_program.
    gettext
  ];

  buildInputs = [
    cutefish-toolkit
    systemd # libsystemd
    pipewire # screencast
    wayland
    wayland-protocols
    libdrm
    libgbm
  ];

  cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  meta = {
    description = "XDG desktop portal backend of the Cutefish desktop";
    homepage = "https://github.com/cutefishos/xdg-desktop-portal-cutefish";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
