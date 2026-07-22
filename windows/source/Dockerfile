FROM vs

COPY --from=source-prep C:\\UnrealEngine C:\\UnrealEngine

WORKDIR C:\\UnrealEngine

COPY patch-setup-win.ps1 C:/
RUN powershell -ExecutionPolicy Bypass -File C:/patch-setup-win.ps1 Setup.bat

ARG setup_args=""
RUN --mount=type=cache,sharing=locked,target=C:/UnrealEngine/.git/ue-gitdeps Setup.bat %setup_args%
