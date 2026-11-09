"""Derive the Visual Studio toolchain required by an Unreal Engine version
from its `Engine/Config/Windows/Windows_SDK.json` file.

Shared between the native Windows image (windows/vs/install-vs.py, which
installs VS Build Tools) and the Wine image (wine/autosdk/parse-sdk-args.py,
which assembles the AutoSDK directory structure with msvc-wine's vsdownload.py).
"""

import re
from pathlib import Path
from typing import Any

try:
    import commentjson
except ImportError:
    import json as commentjson


class VisualStudio:
    """The VS version and the components/workloads suggested by the engine."""

    # VS2022 is preferred; VS2026 is only used if the engine dropped 2022
    supported_versions = (2022, 2026)

    def __init__(self, version: int, major: str, components: list[str], dotnet_sdk: str = ""):
        self.version = version
        self.major = major
        self.components = sorted(set(components))
        self.dotnet_sdk = dotnet_sdk

    @property
    def identifier(self) -> str:
        return f"VS{self.version}"

    @classmethod
    def from_windows_sdk_file(cls, windows_sdk_path: Path) -> "VisualStudio":
        return cls.from_windows_sdk_json(commentjson.loads(Path(windows_sdk_path).read_text(encoding="utf-8")))

    @classmethod
    def from_windows_sdk_json(cls, json_config: Any) -> "VisualStudio":
        # Determine the Visual Studio version that the engine supports
        vs_version = next(
            (v for v in cls.supported_versions if f"MinimumVisualStudio{v}Version" in json_config),
            None,
        )
        if vs_version is None:
            raise ValueError("no MinimumVisualStudio*Version entry found in Windows_SDK.json")

        # Retrieve the Visual Studio major version number
        vs_major = json_config[f"MinimumVisualStudio{vs_version}Version"].split(".", 1)[0]

        # Retrieve the suggested components/workloads (both the general and the version-specific list)
        components = (
            json_config["VisualStudioSuggestedComponents"]
            + json_config[f"VisualStudio{vs_version}SuggestedComponents"]
        )
        # UE-5.4 has buggy component version
        if "Microsoft.VisualStudio.Component.Windows10SDK.22621" in components:
            components.remove("Microsoft.VisualStudio.Component.Windows10SDK.22621")
            components.append("Microsoft.VisualStudio.Component.Windows11SDK.22621")

        if not components:
            raise ValueError("no suggested components found in Windows_SDK.json")

        # Identify which .NET Framework SDK (if any) we need
        pattern = re.compile(r"Microsoft\.Net\.Component\.(4\.[0-9]+\.[0-9]+)\.TargetingPack")
        dotnet_sdk = next((m.group(1) for c in components if (m := pattern.fullmatch(c))), "")

        return cls(vs_version, vs_major, components, dotnet_sdk)
