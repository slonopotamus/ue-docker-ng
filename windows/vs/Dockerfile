FROM base

COPY --from=source-prep C:/UnrealEngine/Engine/Config/Windows/Windows_SDK.json C:/install-vs/Windows_SDK.json
COPY install-vs.ps1 C:/install-vs/
RUN powershell -ExecutionPolicy Bypass -File C:/install-vs/install-vs.ps1 C:/install-vs/Windows_SDK.json
