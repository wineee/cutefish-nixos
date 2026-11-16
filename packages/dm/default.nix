{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gettext,
  pam,
  cutefish-toolkit,
  cutefish-compositor,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-dm";
  version = "1.0-unstable-2026-11-15";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "cutefish-dm";
    rev = "2d06f21aba761b6846c8e10170f5da01addbc8a6";
    hash = "sha256-wlz37PXChZGlNoRRth6QciHydLV6VReTALOHr03xYZU=";
  };

  postPatch = ''
    # Units of a package are collected from $out/lib/systemd.
    substituteInPlace CMakeLists.txt \
      --replace-fail "DESTINATION /usr/lib/systemd/system" "DESTINATION lib/systemd/system" \
      --replace-fail "DESTINATION /usr/lib/systemd/user" "DESTINATION lib/systemd/user"
    substituteInPlace data/cutefish-dm.service \
      --replace-fail "ExecStart=/usr/bin/cutefish-dm" "ExecStart=${placeholder "out"}/bin/cutefish-dm"
    # The login screen is the compositor itself, and sessions are described by
    # desktop entries in the system profile.
    substituteInPlace daemon/config.h \
      --replace-fail '{"/usr/bin/cutefish-compositor", "--login"}' \
        '{"${cutefish-compositor}/bin/cutefish-compositor", "--login"}' \
      --replace-fail '{"/usr/local/share/wayland-sessions", "/usr/share/wayland-sessions"}' \
        '{"/run/current-system/sw/share/wayland-sessions"}'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    # cutefish_add_translations() looks msgfmt up with find_program.
    gettext
  ];

  buildInputs = [
    cutefish-toolkit
    pam
  ];

  cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  meta = {
    description = "Display manager of the Cutefish desktop";
    homepage = "https://github.com/cutefishos/cutefish-dm";
    license = lib.licenses.bsd3;
    mainProgram = "cutefish-dm";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
