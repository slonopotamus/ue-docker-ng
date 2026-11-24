FROM autosdk

# Copy the Installed Build into the image; --chown=ue:ue because a root-owned
# top-level directory would not be writable by the `ue` user under Wine
COPY --from=builder --chown=ue:ue $WINEPREFIX/drive_c/UnrealEngine/LocalBuilds/Engine/Windows $WINEPREFIX/drive_c/UnrealEngine
WORKDIR $WINEPREFIX/drive_c/UnrealEngine
RUN ue_version="$(cat Engine/Build/InstalledBuild.txt)" && \
    wine reg add "HKCU\\SOFTWARE\\Epic Games\\Unreal Engine\\Builds" /v "$ue_version" /t REG_SZ /d "C:\\UnrealEngine" && \
    wineserver --wait
