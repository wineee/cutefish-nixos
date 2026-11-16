{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gettext,
  icu,
  pcre2,
  cutefish-toolkit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-text-editor";
  version = "1.0-unstable-2026-11-15";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "text-editor";
    rev = "11e18eabb53c5de3cfb952d10b77fdb338946d0e";
    hash = "sha256-RPs0v1FnP8Rp58CswXXNrgWAP83HT1/XSz+ktHj8vdc=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    # cutefish_add_translations() looks msgfmt up with plain find_program, so
    # without gettext here the po/ catalogs are skipped without any warning.
    gettext
  ];

  buildInputs = [
    cutefish-toolkit
    icu # ICU_REQUIRED icu-uc
    pcre2 # libpcre2-8, regular-expression search
  ];

  # include(CTest) defaults BUILD_TESTING to ON; the test targets need gtest
  # and gtest_discover_tests runs every test at build time, which needs a live
  # session (text-editor-ui-tests builds a window).
  cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  meta = {
    description = "Text editor of the Cutefish desktop";
    homepage = "https://github.com/cutefishos/text-editor";
    license = lib.licenses.bsd3;
    mainProgram = "cutefish-text-editor";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
