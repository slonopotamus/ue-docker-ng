FROM base

COPY --from=builder --chown=ue:ue /home/ue/UnrealEngine/LocalBuilds/Engine/Linux /home/ue/UnrealEngine
COPY --from=builder --chown=ue:ue /home/ue/.config/Epic/UnrealEngine/Install.ini /home/ue/.config/Epic/UnrealEngine/Install.ini
WORKDIR /home/ue/UnrealEngine
