FROM base

ARG repository=""
ADD --keep-git-dir=true $repository C:/UnrealEngine

# Since the UE4 prerequisites installer appears to break when newer versions
# of the VC++ runtime are present, patch out the prereqs call in Setup.bat
COPY patch-setup-win.py C:/patch-setup-win.py
RUN python C:/patch-setup-win.py C:/UnrealEngine/Setup.bat

# Run post-clone setup steps
# (Note that the \-no-cache\ flag disables caching of dependency data in \.git/ue4-gitdeps\, saving disk space)
RUN C:/UnrealEngine/Setup.bat -no-cache

# Set the changelist number in Build.version to ensure our Build ID is generated correctly
ARG CHANGELIST
COPY set-changelist.py C:/set-changelist.py
RUN python C:/set-changelist.py C:/UnrealEngine/Engine/Build/Build.version %CHANGELIST%
