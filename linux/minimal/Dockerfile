FROM base

# Copy the Installed Build files from the builder image
COPY --from=builder /home/ue/UnrealEngine/LocalBuilds/Engine/Linux /home/ue/UnrealEngine
# Copy Install.ini from the builder image, so it can be used by tools that read the list of engine installations
COPY --from=builder /home/ue/.config/Epic/UnrealEngine/Install.ini /home/ue/.config/Epic/UnrealEngine/Install.ini
WORKDIR /home/ue/UnrealEngine
