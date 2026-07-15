FROM vs

COPY --from=source-prep C:\\UnrealEngine C:\\UnrealEngine

# Since the UE4 prerequisites installer appears to break when newer versions
# of the VC++ runtime are present, patch out the prereqs call in Setup.bat
COPY patch-setup-win.py C:\\patch-setup-win.py
RUN python C:/patch-setup-win.py C:/UnrealEngine/Setup.bat

ARG setup_args=""
RUN C:/UnrealEngine/Setup.bat -no-cache %setup_args%

WORKDIR C:\\UnrealEngine
