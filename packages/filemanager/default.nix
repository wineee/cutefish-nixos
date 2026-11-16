{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  pkg-config,
  gettext,
  icu,
  fuse3,
  libssh,
  libmtp,
  systemd,
  libarchive,
  libzip,
  samba,
  bzip2,
  xz,
  lzfse,
  cutefish-toolkit,
  cutefish-framework,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cutefish-filemanager";
  version = "1.0-unstable-2026-11-15";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "filemanager";
    rev = "5cdf7601a614134975add7f1005dd29564488bee";
    hash = "sha256-e1HIrGvCHQzse3Ll0xE1AbM94+aIbS6oY73sxT5GtkY=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    # cutefish_add_translations() looks msgfmt up with find_program.
    gettext
  ];

  buildInputs = [
    cutefish-toolkit
    cutefish-framework # CutefishFiles
    icu
    fuse3
    libssh
    libmtp
    systemd # libudev, removable devices
    libarchive
    libzip
    samba # smbclient
    # Disk images handled by cutefish-mountd.
    bzip2
    xz # liblzma
    lzfse
  ];

  cmakeFlags = [ "-DBUILD_TESTING=OFF" ];

  meta = {
    description = "File manager of the Cutefish desktop";
    homepage = "https://github.com/cutefishos/filemanager";
    license = lib.licenses.bsd3;
    mainProgram = "cutefish-filemanager";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
