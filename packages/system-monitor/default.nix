{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gettext,
  icu,
  hwdata,
  cutefish-toolkit,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-system-monitor";
  version = "1.0-unstable-2026-11-15";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "system-monitor";
    rev = "4bae09fed43ca46ec78a7672a4845f1c277be680";
    hash = "sha256-6TC9a0Es3418lKsqzlqmIOoqTaRfBEpEWVgdTHdgls0=";
  };

  # GPU names come from the PCI ID database, which only exists in FHS layouts
  # on Debian-derived systems.
  postPatch = ''
    substituteInPlace src/gpureader.cpp \
      --replace-fail '{"/usr/share/misc/pci.ids", "/usr/share/hwdata/pci.ids"}' \
        '{"${hwdata}/share/hwdata/pci.ids", "/usr/share/hwdata/pci.ids"}'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    # cutefish_add_translations() looks msgfmt up with find_program.
    gettext
  ];

  buildInputs = [
    cutefish-toolkit
    icu
    hwdata
  ];

  cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  meta = {
    description = "System monitor of the Cutefish desktop";
    homepage = "https://github.com/cutefishos/system-monitor";
    license = lib.licenses.bsd3;
    mainProgram = "cutefish-system-monitor";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
