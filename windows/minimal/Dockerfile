FROM vs

# Copy the Installed Build files from the builder image
COPY --from=builder C:/UnrealEngine/LocalBuilds/Engine/Windows C:/UnrealEngine
COPY --from=builder C:/UnrealEngine/Components/Binaries C:/UnrealEngine
COPY --from=builder C:/UnrealEngine/Components/Content C:/UnrealEngine
COPY --from=builder C:/UnrealEngine/Components/Extras C:/UnrealEngine
COPY --from=builder C:/UnrealEngine/Components/Intermediate C:/UnrealEngine
COPY --from=builder C:/UnrealEngine/Components/Plugins C:/UnrealEngine
COPY --from=builder C:/UnrealEngine/Components/Source C:/UnrealEngine
COPY --from=builder C:/UnrealEngine/Components/DebugSymbols C:/UnrealEngine
COPY --from=builder C:/UnrealEngine/Components/TemplatesAndSamples C:/UnrealEngine
WORKDIR C:/UnrealEngine
