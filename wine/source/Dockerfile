FROM autosdk

# Copy the Unreal Engine source tree into the image containing the AutoSDK toolchain
COPY --from=source-prep --chown=ue:ue $WINEPREFIX/drive_c/UnrealEngine $WINEPREFIX/drive_c/UnrealEngine

# Remove the ADOSupport plugin, which breaks compilation under Wine
# (It has been unused for many years and was officially removed in CL 50213900)
RUN rm -rf "$WINEPREFIX/drive_c/UnrealEngine/Engine/Plugins/Runtime/Database/ADOSupport"

# Patch Setup.bat the same way as on Windows (skip the version selector, no pause on error)
COPY --from=shared patch-setup-win.py /tmp/patch-setup-win.py
RUN python3 /tmp/patch-setup-win.py "$WINEPREFIX/drive_c/UnrealEngine/Setup.bat"

# Run Setup.bat to sync install-only engine dependencies (e.g. the bundled .NET
# SDK under Engine/Binaries/ThirdParty/DotNet) that are not part of the git tree
ARG setup_args=""
RUN --mount=type=cache,sharing=locked,target=$WINEPREFIX/drive_c/UnrealEngine/.git/ue-gitdeps,uid=1001,gid=1001 \
  wine "C:\UnrealEngine\Setup.bat" $setup_args

WORKDIR $WINEPREFIX/drive_c/UnrealEngine
