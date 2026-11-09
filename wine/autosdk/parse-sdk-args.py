#!/usr/bin/env python3
"""Derive the Windows toolchain components required by an Unreal Engine
version from its `Engine/Config/Windows/Windows_SDK.json` file and write
them to a shell env file that can be sourced by subsequent build steps.

Adapted from the WineResources project by Epic Games (MIT licensed):
https://github.com/EpicGames/WineResources/blob/main/examples/quickstart/autosdk/assemble.py
"""

import sys
from pathlib import Path

from vs import VisualStudio

# Components/workloads that are not required when assembling the AutoSDK directory structure (e.g. IDE workloads)
ignored = ["Component.Unreal", "Microsoft.VisualStudio.Workload"]


def main():
    if len(sys.argv) != 3:
        sys.exit(f"usage: {sys.argv[0]} <Windows_SDK.json> <output env file>")

    vs = VisualStudio.from_windows_sdk_file(Path(sys.argv[1]))

    # Filter out any components/workloads that we know are not required (e.g. IDE workloads)
    components = [component for component in vs.components if len([phrase for phrase in ignored if phrase in component]) == 0]
    if len(components) == 0:
        raise ValueError("no suggested components found in Windows_SDK.json")

    # Although the suggested components may list a .NET Framework targeting pack, we actually need the SDK
    is_targeting_pack = lambda c: c.startswith("Microsoft.Net.Component") and c.endswith("TargetingPack")
    components = [
        component.replace("TargetingPack", "SDK") if is_targeting_pack(component) else component
        for component in components
    ]

    lines = [
        f'COMPONENTS_AND_WORKLOADS="{" ".join(components)}"',
        f'DOTNET_FRAMEWORK_SDK="{vs.dotnet_sdk}"',
        f'VISUAL_STUDIO_IDENTIFIER="{vs.identifier}"',
        f'VISUAL_STUDIO_VERSION="{vs.major}"',
    ]
    Path(sys.argv[2]).write_text("\n".join(lines) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
