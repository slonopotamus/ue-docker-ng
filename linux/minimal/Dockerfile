FROM base

COPY --from=builder /home/ue/UnrealEngine/LocalBuilds/Engine/Linux /home/ue/UnrealEngine
COPY --from=builder /home/ue/.config/Epic/UnrealEngine/Install.ini /home/ue/.config/Epic/UnrealEngine/Install.ini
WORKDIR /home/ue/UnrealEngine
