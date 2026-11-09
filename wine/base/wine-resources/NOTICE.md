# Vendored from EpicGames/WineResources

The files in this directory are vendored from the
[WineResources](https://github.com/EpicGames/WineResources) repository by
Epic Games, Inc., licensed under the MIT License (see `LICENSE`).

- Upstream commit: `692e0d8ada68ff3640d06df34a5a609dfbf3c086` (2026-08-05)

| Vendored file | Upstream path |
|---|---|
| `msbuild/` | `build/template/msbuild/` |

`wine/base/Dockerfile` is also derived from this repository: its `runtime`
and `mitigations` stages mirror the corresponding stages of
`build/template/template.dockerfile.j2` (same commit). The Wine source build
stages of that template are not used: Wine is installed from the WineHQ apt
repository (the `wine-devel` channel), which on resolute (Ubuntu 26.04) only
ships prebuilt 64-bit packages, so the source-build-only files (build
dependencies, patches, the memory shim, libmemory-patches and the symbol file
indexer) are no longer vendored.
