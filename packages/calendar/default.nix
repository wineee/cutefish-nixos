{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gettext,
  icu,
  libical,
  curl,
  cutefish-toolkit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-calendar";
  version = "1.0-unstable-2026-11-15";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "calendar";
    rev = "4332987418637a78d3d302159ec74bb5de57d4e2";
    hash = "sha256-KusBw20MuyLXywiskmadHdIEccc8Xt7ubrbCnLyWgaQ=";
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
    libical
    curl
  ];

  cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  meta = {
    description = "Calendar of the Cutefish desktop";
    homepage = "https://github.com/cutefishos/calendar";
    license = lib.licenses.bsd3;
    mainProgram = "cutefish-calendar";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
