{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gettext,
  icu,
  mpv,
  cutefish-toolkit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-video-player";
  version = "1.0-unstable-2026-11-15";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "video-player";
    rev = "bfb4dca179d5f5f000c0eb1a4a1fc20c24f560d2";
    hash = "sha256-9fkPK//d+b3MLzQ3RPBu0ECY00TO3bRyRunV4zQRU4o=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    # cutefish_add_translations() looks msgfmt up with find_program.
    gettext
  ];

  buildInputs = [
    cutefish-toolkit
    icu
    mpv
  ];

  cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  meta = {
    description = "Video player of the Cutefish desktop";
    homepage = "https://github.com/cutefishos/video-player";
    license = lib.licenses.bsd3;
    mainProgram = "cutefish-video-player";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
