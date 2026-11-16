{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  gettext,
  cutefish-toolkit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-calculator";
  version = "1.0-unstable-2026-11-15";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "calculator";
    rev = "d8af2924007933ca72f25ab19acc1c8e82c68927";
    hash = "sha256-GwexYzHoF4qnu9k30Y6tw6J1PUvgXJK60P6ApOhUMgo=";
  };

  nativeBuildInputs = [
    cmake
    # cutefish_add_translations() looks msgfmt up with find_program.
    gettext
  ];

  buildInputs = [ cutefish-toolkit ];

  # include(CTest) turns BUILD_TESTING on, and the tests need GTest.
  cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  meta = {
    description = "Calculator of the Cutefish desktop";
    homepage = "https://github.com/cutefishos/calculator";
    license = lib.licenses.bsd3;
    mainProgram = "cutefish-calculator";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
