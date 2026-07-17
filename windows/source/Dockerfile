FROM vs

COPY --from=source-prep C:\\UnrealEngine C:\\UnrealEngine

WORKDIR C:\\UnrealEngine

# Since the UE4 prerequisites installer appears to break when newer versions
# of the VC++ runtime are present, patch out the prereqs call in Setup.bat
COPY patch-setup-win.py C:\\patch-setup-win.py
RUN python C:/patch-setup-win.py Setup.bat

ARG setup_args=""
RUN --mount=type=cache,sharing=locked,target=C:/UnrealEngine/.git/ue-gitdeps Setup.bat %setup_args%
