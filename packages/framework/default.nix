{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gettext,
  icu,
  libpng,
  pipewire,
  cutefish-toolkit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-framework";
  version = "1.0-unstable-2026-11-15";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "cutefish-framework";
    rev = "15174d3b9d76132dc5ffd82794f1f1cd617be8f2";
    hash = "sha256-CzuHzYi2tYqysYEU+txxWP2mBRASuaR3kYZ7+I85vGQ=";
  };

  # The PDF library wants a PDFium checkout it compiles itself
  # (scripts/fetch-pdfium.sh); nothing packaged here links Cutefish::Pdf yet.
  patches = [ ./framework-optional-pdf.patch ];

  # The account presets ship in cutefish-wallpapers, which must not become a
  # dependency of a library (and is unfree), so look them up in the profile.
  postPatch = ''
    substituteInPlace clients/accounts/account_picture.h \
      --replace-fail '"/usr/share/cutefish/avatars"' \
        '"/run/current-system/sw/share/cutefish/avatars"'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    # cutefish_add_translations() looks msgfmt up with find_program.
    gettext
  ];

  buildInputs = [
    cutefish-toolkit
    icu # files: icu-uc
    libpng # files: thumbnails
    pipewire # audio client: libpipewire-0.3 >= 0.3.65, libspa-0.2
  ];

  # include(CTest) turns BUILD_TESTING on, and most of these talk to system
  # services (UPower, NetworkManager, BlueZ, PipeWire) that do not exist in
  # the build sandbox.
  cmakeFlags = [
    "-DBUILD_TESTING=OFF"
    "-DCUTEFISH_FRAMEWORK_PDF=OFF"
  ];

  meta = {
    description = "Clients of the system services used by the Cutefish desktop";
    homepage = "https://github.com/cutefishos/cutefish-framework";
    license = lib.licenses.bsd3;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
