FROM base

COPY --from=builder --chown=ue:ue /home/ue/UnrealEngine/LocalBuilds/Engine/Linux /home/ue/UnrealEngine
WORKDIR /home/ue/UnrealEngine
RUN ue_version="$(<Engine/Build/InstalledBuild.txt)" && \
    mkdir -p /home/ue/.config/Epic/UnrealEngine/ \
    && echo "[Installations]\n${ue_version}=/home/ue/UnrealEngine" >/home/ue/.config/Epic/UnrealEngine/Install.ini
