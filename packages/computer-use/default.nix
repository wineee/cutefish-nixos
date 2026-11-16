{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "cutefish-computer-use";
  version = "1.0-unstable-2026-11-14";

  # Upstream ships a .cargo/config.toml that redirects crates.io to Debian's
  # offline /usr/share/cargo/registry; drop it before vendoring and building.
  src = stdenv.mkDerivation {
    pname = "${finalAttrs.pname}-src";
    version = finalAttrs.version;
    src = fetchFromGitHub {
      owner = "cutefishos";
      repo = "cutefish-computer-use";
      rev = "785bf14844d4e9e7b816f6a8bd29949a0b3b3e7b";
      hash = "sha256-M2pX2a2UjN9kZZf177gyKD5wHloPrZdgjxKSlcBFD4o=";
    };
    installPhase = ''
      runHook preInstall
      cp -a . $out
      rm -f $out/.cargo/config.toml
      # Upstream does not commit a lockfile; Nix's cargo vendoring needs one.
      cp ${./Cargo.lock} $out/Cargo.lock
      runHook postInstall
    '';
  };

  cargoHash = "sha256-ceKYYGsskoh2soxdnYqPUUd/gNXCfqP8bMWf1LYD/0k=";

  meta = {
    description = "MCP server that lets agent apps see and use the Cutefish desktop";
    homepage = "https://github.com/cutefishos/cutefish-computer-use";
    license = lib.licenses.bsd3;
    mainProgram = "cutefish-computer-use";
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ wineee ];
  };
})
