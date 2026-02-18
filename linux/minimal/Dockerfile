FROM base

# Copy the Installed Build files from the builder image
COPY --from=builder --chown=ue:ue /home/ue/UnrealEngine/LocalBuilds/Engine/Linux /home/ue/UnrealEngine
COPY --from=builder --chown=ue:ue /home/ue/UnrealEngine/Components/Binaries /home/ue/UnrealEngine
COPY --from=builder --chown=ue:ue /home/ue/UnrealEngine/Components/Content /home/ue/UnrealEngine
COPY --from=builder --chown=ue:ue /home/ue/UnrealEngine/Components/Extras /home/ue/UnrealEngine
COPY --from=builder --chown=ue:ue /home/ue/UnrealEngine/Components/Intermediate /home/ue/UnrealEngine
COPY --from=builder --chown=ue:ue /home/ue/UnrealEngine/Components/Plugins /home/ue/UnrealEngine
COPY --from=builder --chown=ue:ue /home/ue/UnrealEngine/Components/Source /home/ue/UnrealEngine
COPY --from=builder --chown=ue:ue /home/ue/UnrealEngine/Components/DebugSymbols /home/ue/UnrealEngine
# Copy Install.ini from the builder image, so it can be used by tools that read the list of engine installations (e.g. ushell)
COPY --from=builder --chown=ue:ue /home/ue/.config/Epic/UnrealEngine/Install.ini /home/ue/.config/Epic/UnrealEngine/Install.ini
WORKDIR /home/ue/UnrealEngine
