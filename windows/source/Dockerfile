FROM vs

COPY --from=source-prep C:/UnrealEngine C:/UnrealEngine

# Since the UE4 prerequisites installer appears to break when newer versions
# of the VC++ runtime are present, patch out the prereqs call in Setup.bat
COPY --link patch-setup-win.py C:/patch-setup-win.py
RUN python C:/patch-setup-win.py C:/UnrealEngine/Setup.bat

# Run post-clone setup steps
# (Note that the \-no-cache\ flag disables caching of dependency data in \.git/ue4-gitdeps\, saving disk space)
RUN C:/UnrealEngine/Setup.bat -no-cache --exclude=Android --exclude=Mac --exclude=Linux

WORKDIR C:/UnrealEngine
