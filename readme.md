# cutefish-nixos

Cutefish desktop environment for NixOS — packages, NixOS module and a debug VM.

Split out of [`wineee/dde-cutefish-for-nixos`](https://github.com/wineee/dde-cutefish-for-nixos);
the DDE port lives there, the two repositories share nothing.

> [!WARNING]
> **Experimental — please read before using.**
>
> - **Package definitions, patches, the NixOS module and the docs are largely
>   produced by coding agents.** They are **not guaranteed** to meet the
>   standards nixpkgs requires for merge, and are not meant to be upstreamed
>   as-is.
> - **Real-hardware boot is unverified.** All 17 packages and the VM image
>   build, but starting the session needs a working DRM/EGL device, which the
>   build sandbox does not have. Treat this as a porting workbench.

## Usage

```nix
{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    cutefish-nixos = {
      url = "github:wineee/cutefish-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, cutefish-nixos, ... }:
    {
      nixosConfigurations.<hostname> = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          cutefish-nixos.nixosModules.cutefish
          {
            # Wallpapers are unfree (Unsplash License).
            nixpkgs.config.allowUnfree = true;
            services.desktopManager.cutefish.enable = true;
          }
          ./configuration.nix
        ];
      };
    };
}
```

`services.desktopManager.cutefish.enable` brings in the applications, the
`cutefish-wayland` session, `cutefish-dm`, the XDG portal and the artwork in
one go. Fine-grained switches:

```nix
services.desktopManager.cutefish.displayManager.enable = false;  # no cutefish-dm
services.cutefish.artwork.enable = true;                         # icons/wallpapers only
services.cutefish.artwork.wallpapers.enable = false;             # skip the unfree ones
```

Non-flake setups go through `flake-compat` with
`https://github.com/wineee/cutefish-nixos/archive/main.tar.gz`.

## Building

```bash
nix build .#cutefish-toolkit --no-link   # single package
nix flake show                           # everything exposed
cd vm && nix run                         # debug VM (needs host GPU)
```

## Documentation

- [docs/survey.md](docs/survey.md) — upstream survey, progress, remaining work
- [docs/toolkit.md](docs/toolkit.md) — Skia build and `cutefish-toolkit`
- [docs/core.md](docs/core.md) — session, background services, display manager
- [docs/apps.md](docs/apps.md) — applications, portal, artwork, Qt plugins

## Layout

```
flake.nix             # packages.<system>.*, nixosModules.cutefish, legacyPackages.cutefish
packages/default.nix  # the whole package set (lib.fix over callPackage)
packages/<pkg>/       # one directory per derivation, patches next to it
nixos-modules/        # desktop entry, cutefish-dm, artwork
vm/                   # separate flake: qemu-vm + cutefish session
src/                  # upstream clones for analysis (gitignored)
docs/
```

## Status

17 packages build: `cutefish-skia`, `cutefish-toolkit`, `cutefish-framework`,
`cutefish-compositor`, `cutefish-core`, `cutefish-dm`, `cutefish-icons`,
`cutefish-wallpapers`, `cutefish-qt-plugins`, `xdg-desktop-portal-cutefish`,
`cutefish-terminal`, `cutefish-text-editor`, `cutefish-filemanager`,
`cutefish-settings`, `cutefish-calendar`, `cutefish-video-player`,
`cutefish-system-monitor`.

Not packaged: `cutefish-computer-use` (Rust, no `Cargo.lock` upstream);
`cutefish-installer` is not needed on NixOS.

Upstream publishes no tags and moves daily, so every package pins a commit;
`toolkit`/`framework`/`compositor`/`core` speak private Wayland protocols and
have to be bumped together.

## References

- [nix-cutefish](https://github.com/p3psi-boo/nix-cutefish)
- [cutefishos](https://github.com/cutefishos)

## License

MIT
