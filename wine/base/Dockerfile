# syntax=docker/dockerfile:1.7-labs
#
# Based on the WineResources project by Epic Games (MIT licensed):
# https://github.com/EpicGames/WineResources
#
# The runtime environment (non-root `ue` user, Wine prefix, Wine Mono,
# Windows Mono with MSBuild, .NET Framework reference assemblies and the
# .NET trust lists) mirrors the `runtime` and `mitigations` stages of
# WineResources' build/template/template.dockerfile.j2 (upstream commit
# 692e0d8ada68ff3640d06df34a5a609dfbf3c086), but Wine itself is installed
# from the WineHQ apt repository (the `wine-devel` channel) instead of
# being built from source with Epic's patches.
#
# Notes:
# - The WineHQ resolute (Ubuntu 26.04) repository only carries `wine-devel`
#   for amd64, so the resulting Wine is 64-bit only (no wine32 support).
# - The source-build-only parts of the WineResources template (build
#   dependencies, LLVM-MinGW, libcgroup, the memory shim,
#   libmemory-patches, the source patches and the `artifacts` stage) are
#   therefore no longer present.
#
# Note: the base image must be based on Ubuntu 26.04
FROM base AS runtime

# Disable interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Install Wine from the WineHQ apt repository (the `wine-devel` channel)
# Note: the archive key is de-armed, since recent apt ignores ASCII-armored keyring files
RUN rm -f /etc/apt/apt.conf.d/docker-clean; echo 'Binary::apt::APT::Keep-Downloaded-Packages "true";' > /etc/apt/apt.conf.d/keep-cache
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked \
	apt-get update && apt-get install -y ca-certificates curl gnupg && \
	mkdir -pm755 /etc/apt/keyrings && \
	curl -fsSL https://dl.winehq.org/wine-builds/winehq.key | gpg --dearmor -o /etc/apt/keyrings/winehq-archive.key && \
	curl -fsSL -o /etc/apt/sources.list.d/winehq-resolute.sources https://dl.winehq.org/wine-builds/ubuntu/dists/resolute/winehq-resolute.sources && \
	apt-get update && \
	apt-get install -y wine-devel

# The 11.x packages install everything under /opt/wine-devel, so expose the
# binaries on the PATH (`wine` is the 64-bit launcher)
ENV PATH=/opt/wine-devel/bin:$PATH

# Install the runtime dependencies that are not pulled in by the `wine-devel`
# package itself:
# - `gstreamer1.0-plugins-base` provides the actual plugins (the `wine-devel`
#   package only pulls in the GStreamer libraries)
# - `libvulkan1` provides the Vulkan loader/ICD needed by the engine
# - `git`, `git-lfs`, `msitools`, `python3`, `sudo`, `unzip`, `tzdata` and
#   `xvfb` are used by the build pipeline and by Windows apps running under Wine
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked \
	apt-get update && apt-get install -y \
		git \
		git-lfs \
		gstreamer1.0-plugins-base \
		libgnutls-openssl27t64 \
		libvulkan1 \
		msitools \
		python3 \
		sudo \
		tzdata \
		unzip \
		winbind \
		xvfb

# Configure the container's locale settings
# (Note: without this, the locale will default to ANSI_X3.4-1968 / US-ASCII, which interferes with Wine's Unicode character handling)
ENV LANG=en_US.UTF-8
RUN --mount=type=cache,target=/var/cache/apt,sharing=locked --mount=type=cache,target=/var/lib/apt,sharing=locked \
	apt-get update && apt-get install -y locales && \
	sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
	locale-gen && \
	update-locale LANG="${LANG}"

# Create the non-root `ue` user with no password and allow it to run commands using sudo
# (same user as in linux/base/Dockerfile; uid/gid 1000 is already taken by the `ubuntu`
# user that ships with the official Ubuntu base image, so use 1001)
RUN useradd --create-home --home /home/ue --shell /bin/bash --uid 1001 ue && \
  passwd -d ue && \
  usermod -a -G audio,video,sudo ue

# Create a new 64-bit Wine prefix for our non-root user
ENV WINEARCH=win64
ENV WINEPREFIX=/home/ue/.local/share/wineprefixes/prefix
USER ue
RUN mkdir -p "$WINEPREFIX"
RUN wineboot && wineserver --wait

# Enable Git Large File Storage (LFS) support
RUN git lfs install

# Preinstall Wine Mono
RUN curl -fSL 'https://github.com/madewokherd/wine-mono/releases/download/wine-mono-10.1.0/wine-mono-10.1.0-x86.msi' -o /tmp/wine-mono-x86.msi && \
	wine msiexec /quiet /i /tmp/wine-mono-x86.msi && \
	wineserver --wait && \
	rm /tmp/wine-mono-x86.msi

# Prevent Wine from attempting to display a dialog box in the event of a crash
# (Without this, execution may hang when running with Xvfb in a headless environment)
RUN wine reg add "HKCU\\Software\\Wine\\WineDbg" /f /v ShowCrashDialog /t REG_DWORD /d 0 && wineserver --wait

# Disable the Wine debugger
# Setting this option to "false" will prevent the debugger from starting
# https://gitlab.winehq.org/wine/wine/-/wikis/Useful-Registry-Keys
RUN wine reg add "HKLM\\Software\\Microsoft\\Windows NT\\CurrentVersion\\AeDebug" /f /v Debugger /t REG_SZ /d "false" && wineserver --wait

# The version of MSBuild that comes bundled with Mono is a batch file, but UAT expects an executable,
# so we build a tiny wrapper that runs the batch file and forwards all supplied command-line arguments
FROM golang:1.21-bookworm AS wrapper
COPY wine-resources/msbuild/MSBuildWrapper.go /tmp/MSBuildWrapper.go
RUN GOOS=windows GOARCH=amd64 go build -o /tmp/MSBuildWrapper.exe /tmp/MSBuildWrapper.go

FROM runtime AS mitigations

# Add the Microsoft root certificate trust lists for code signing and timestamping used by .NET for NuGet signing and validation
USER root
RUN \
	curl -fSL 'https://raw.githubusercontent.com/dotnet/sdk/bdbc1e8e8db13bcba0b3f9e9e26573c2a4b0f5bd/src/Layout/redist/trustedroots/codesignctl.pem' -o /usr/local/share/ca-certificates/codesignctl.crt && \
	curl -fSL 'https://raw.githubusercontent.com/dotnet/sdk/bdbc1e8e8db13bcba0b3f9e9e26573c2a4b0f5bd/src/Layout/redist/trustedroots/timestampctl.pem' -o /usr/local/share/ca-certificates/timestampctl.crt && \
	update-ca-certificates
USER ue

# Copy our system-wide MSBuild property overrides files into the image
RUN mkdir -p \
	"${WINEPREFIX}/drive_c/users/ue/AppData/Local/Microsoft/MSBuild/Current/Imports/Microsoft.Common.props/ImportAfter" \
	"${WINEPREFIX}/drive_c/users/ue/AppData/Local/Microsoft/MSBuild/Current/Microsoft.NETFramework.props/ImportAfter"
COPY --chown=ue:ue wine-resources/msbuild/Custom.After.Microsoft.Common.Props "${WINEPREFIX}/drive_c/users/ue/AppData/Local/Microsoft/MSBuild/Current/Imports/Microsoft.Common.props/ImportAfter/Custom.After.Microsoft.Common.Props"
COPY --chown=ue:ue wine-resources/msbuild/Custom.After.Microsoft.NETFramework.Props "${WINEPREFIX}/drive_c/users/ue/AppData/Local/Microsoft/MSBuild/Current/Microsoft.NETFramework.props/ImportAfter/Custom.After.Microsoft.NETFramework.Props"

# The Wine version of Mono doesn't include MSBuild, so we install the Windows version of upstream Mono, which does include MSBuild
RUN curl -fSL 'https://download.mono-project.com/archive/6.12.0/windows-installer/mono-6.12.0.199-x64-0.msi' -o /tmp/mono-x64.msi && \
	wine msiexec /i /tmp/mono-x64.msi && \
	wineserver --wait && \
	rm /tmp/mono-x64.msi

# Create the directory to hold the .NET Framework reference assemblies
RUN mkdir -p "${WINEPREFIX}/drive_c/Program Files (x86)/Reference Assemblies/Microsoft/Framework/.NETFramework"

# Extract the .NET Framework 4.6.2 reference assemblies from the official NuGet package
RUN curl -fSL 'https://www.nuget.org/api/v2/package/Microsoft.NETFramework.ReferenceAssemblies.net462/1.0.3' -o /tmp/net462.nupkg && \
	unzip /tmp/net462.nupkg -d /tmp/net462 && \
	cp -R /tmp/net462/build/.NETFramework/v4.6.2 "${WINEPREFIX}/drive_c/Program Files (x86)/Reference Assemblies/Microsoft/Framework/.NETFramework/v4.6.2" && \
	rm -rf /tmp/net462 /tmp/net462.nupkg

# Copy our MSBuild wrapper executable alongside Mono's MSBuild batch file
COPY --from=wrapper --chown=ue:ue ["/tmp/MSBuildWrapper.exe", "/home/ue/.local/share/wineprefixes/prefix/drive_c/Program Files/Mono/bin/MSBuild.exe"]

# Set the Visual Studio telemetry opt-out value for 64-bit applications
RUN wine reg add "HKLM\\SOFTWARE\\Microsoft\\VSCommon\\17.0\\SQM" /f /v OptIn /t REG_DWORD /d 0 && wineserver --wait

# Set the Visual Studio telemetry opt-out value for 32-bit applications
RUN wine reg add "HKLM\\SOFTWARE\\Wow6432Node\\Microsoft\\VSCommon\\17.0\\SQM" /f /v OptIn /t REG_DWORD /d 0 && wineserver --wait
