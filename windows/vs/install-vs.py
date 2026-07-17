import subprocess
import sys
import urllib.request
from pathlib import Path
from typing import Any

import jsonc

common_components = [
    "Microsoft.Net.ComponentGroup.DevelopmentPrerequisites",
    "Microsoft.VisualStudio.Component.NuGet",
    "Microsoft.VisualStudio.Workload.VCTools",
    "Microsoft.VisualStudio.Workload.MSBuildTools",
]

vs2022_components = common_components + [
    "Microsoft.NetCore.Component.SDK",
]


def build_vs_channel_url(vs_version: str) -> str:
    version_major = vs_version.split(".", 1)[0]
    return f"https://aka.ms/vs/{version_major}/release.ltsc.{vs_version}/channel"


class VisualStudio:
    def __init__(self, version: str, channel_url: str, components: list[str]):
        self.version = version
        self.channel_url = channel_url
        self.components = sorted(set(components))

    @classmethod
    def from_json(cls, json_config: Any) -> "VisualStudio":
        # TODO: Add option to request VS2026

        vs_version = json_config["MinimumVisualStudio2022Version"]

        components = (
            vs2022_components
            + json_config["VisualStudioSuggestedComponents"]
            + json_config["VisualStudio2022SuggestedComponents"]
        )

        # UE-5.4 has buggy component version
        if "Microsoft.VisualStudio.Component.Windows10SDK.22621" in components:
            components.remove("Microsoft.VisualStudio.Component.Windows10SDK.22621")
            components.append("Microsoft.VisualStudio.Component.Windows11SDK.22621")

        return cls(
            vs_version,
            build_vs_channel_url(vs_version),
            components,
        )

    def download_installer(self, installer_path: Path) -> None:
        print(f"Downloading Visual Studio {self.version}...")
        urllib.request.urlretrieve(
            "https://aka.ms/vs/17/release/vs_buildtools.exe", installer_path
        )

    def install(self, installer_path: Path) -> None:
        argv = [
            installer_path,
            "--quiet",
            "--wait",
            "--channelUri",
            self.channel_url,
            "--productId",
            "Microsoft.VisualStudio.Product.BuildTools",
            "--norestart",
            "--nocache",
            "--installPath",
            "C:/BuildTools",
            "--locale",
            "en-US",
        ]

        print(f"Installing Visual Studio {self.version}...")
        print("Components:")
        for component in self.components:
            argv.append("--add")
            argv.append(component)
            print(f" * {component}")

        sys.stdout.flush()

        subprocess.run(argv, check=True)


if __name__ == "__main__":
    windows_sdk_path = Path(sys.argv[1])
    windows_sdk_json = jsonc.loads(windows_sdk_path.read_text(encoding="utf-8"))
    vs = VisualStudio.from_json(windows_sdk_json)

    vs_installer_path = Path("C:/vs_buildtools.exe")
    vs.download_installer(vs_installer_path)
    vs.install(vs_installer_path)
