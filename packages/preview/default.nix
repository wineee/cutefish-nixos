{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gettext,
  libpng,
  cutefish-toolkit,
  cutefish-framework,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-preview";
  version = "1.0-unstable-2026-11-15";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "preview";
    rev = "b1d57ca700378cc223b5a8b68834d4a9cbb69428";
    hash = "sha256-8cWOiA7OyV/DhbeMEq9yrFv7mJ3T65GxPwnw7BvleVM=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    # cutefish_add_translations() looks msgfmt up with find_program.
    gettext
  ];

  # CutefishFiles and CutefishPdf both come from the framework.
  buildInputs = [
    cutefish-toolkit
    cutefish-framework
    libpng
  ];

  # include(CTest) turns BUILD_TESTING on; the tests need GTest and the
  # encoders' own writers.
  cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  meta = {
    description = "Image and PDF viewer of the Cutefish desktop";
    homepage = "https://github.com/cutefishos/preview";
    license = lib.licenses.bsd3;
    mainProgram = "cutefish-preview";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
