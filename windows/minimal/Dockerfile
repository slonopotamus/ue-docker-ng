FROM vs

COPY --from=builder C:/UnrealEngine/LocalBuilds/Engine/Windows C:/UnrealEngine
WORKDIR C:/UnrealEngine
RUN set /p ue_version=<Engine\Build\InstalledBuild.txt && \
    call reg add "HKCU\SOFTWARE\Epic Games\Unreal Engine\Builds" /v %ue_version% /t REG_SZ /d "C:\UnrealEngine"
