import subprocess
import sys
import urllib.request
from pathlib import Path

from vs import VisualStudio

common_components = [
    "Microsoft.Net.ComponentGroup.DevelopmentPrerequisites",
    "Microsoft.VisualStudio.Component.NuGet",
    "Microsoft.VisualStudio.Workload.VCTools",
    "Microsoft.VisualStudio.Workload.MSBuildTools",
]

vs2022_components = common_components + [
    "Microsoft.NetCore.Component.SDK",
]


def download_installer(vs: VisualStudio, installer_path: Path) -> None:
    print(f"Downloading Visual Studio {vs.major}...")
    urllib.request.urlretrieve(
        f"https://aka.ms/vs/{vs.major}/release/vs_buildtools.exe", installer_path
    )


def install(vs: VisualStudio, components: list[str], installer_path: Path) -> None:
    argv = [
        installer_path,
        "--quiet",
        "--wait",
        "--productId",
        "Microsoft.VisualStudio.Product.BuildTools",
        "--norestart",
        "--nocache",
        "--installPath",
        "C:/BuildTools",
        "--locale",
        "en-US",
    ]

    print(f"Installing Visual Studio {vs.major}...")
    print("Components:")
    for component in components:
        argv.append("--add")
        argv.append(component)
        print(f" * {component}")

    sys.stdout.flush()

    subprocess.run(argv, check=True)


if __name__ == "__main__":
    vs = VisualStudio.from_windows_sdk_file(Path(sys.argv[1]))

    components = (
        vs2022_components if vs.version == 2022 else common_components
    ) + vs.components

    vs_installer_path = Path("C:/vs_buildtools.exe")
    download_installer(vs, vs_installer_path)
    install(vs, components, vs_installer_path)
