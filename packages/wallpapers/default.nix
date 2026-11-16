{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-wallpapers";
  version = "1.0-unstable-2026-11-13";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "wallpapers";
    rev = "d0e37fb7e9a6498b0d5f31c51a7df3facbae15c9";
    hash = "sha256-vynkQpABKXa/tiv0IogOcthfeZiL8guYpeCw28bjpFw=";
  };

  nativeBuildInputs = [ cmake ];

  # Data only: CMake is used for its install rules, there is nothing to build.
  # (stdenv, not stdenvNoCC: the top-level project() enables C/CXX.)
  dontBuild = true;

  # Upstream installs to the absolute /usr/share/backgrounds; the account
  # presets moved into share/cutefish/avatars with the same problem.
  postPatch = ''
    substituteInPlace sources/CMakeLists.txt \
      --replace-fail "/usr/share/backgrounds/cutefishos" "share/backgrounds/cutefishos"
    substituteInPlace avatars/CMakeLists.txt \
      --replace-fail "/usr/share/cutefish/avatars" "share/cutefish/avatars"
  '';

  meta = {
    description = "Wallpapers for the Cutefish desktop";
    homepage = "https://github.com/cutefishos/wallpapers";
    # Unsplash License: free to use and redistribute, but photos may not be
    # resold unmodified nor compiled into a competing service.
    license = lib.licenses.unfreeRedistributable;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
