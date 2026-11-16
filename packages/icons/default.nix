{
  stdenvNoCC,
  lib,
  fetchFromGitHub,
  cmake,
  gtk3,
  hicolor-icon-theme,
  kdePackages,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cutefish-icons";
  version = "1.0-unstable-2026-11-15";

  src = fetchFromGitHub {
    owner = "cutefishos";
    repo = "icons";
    rev = "308488e092134ae2a1f346ab28ad8cec596c5cb5";
    hash = "sha256-MywdtvWDQy47w3VInPIreP+xv8tripUNtXT4yPcdE10=";
  };

  nativeBuildInputs = [
    cmake
    gtk3 # gtk-update-icon-cache, run by the install script
  ];

  # index.theme: Inherits=hicolor,breeze
  propagatedBuildInputs = [
    hicolor-icon-theme
    kdePackages.breeze-icons
  ];

  # The install script honours INSTALL_PREFIX instead of guessing /usr.
  cmakeFlags = [ "-DINSTALL_PREFIX=${placeholder "out"}" ];

  # links/ ships symlinks into inherited themes, so dangling ones are expected.
  dontCheckForBrokenSymlinks = true;

  # breeze-icons propagates qtbase; there is nothing to wrap here.
  dontWrapQtApps = true;

  meta = {
    description = "Icon theme for the Cutefish desktop";
    homepage = "https://github.com/cutefishos/icons";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
