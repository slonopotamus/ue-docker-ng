FROM source-with-vs AS builder

# Remove the .git directory to disable UBT `git status` calls and speed up the build process
RUN if exist C:/UnrealEngine/.git rmdir /s /q C:/UnrealEngine/.git

# Create an Installed Build of the Engine
WORKDIR C:/UnrealEngine
RUN ./Engine/Build/BatchFiles/RunUAT.bat BuildGraph \
	-target="Make Installed Build Win64" \
	-script=Engine/Build/InstalledEngineBuild.xml \
	-set:HostPlatformOnly=true \
	-set:WithClient=true \
	-set:WithDDC=false \
	-set:WithServer=true \
	{{ buildgraph_args }} && \
	(if exist C:/UnrealEngine/LocalBuilds/InstalledDDC rmdir /s /q C:/UnrealEngine/LocalBuilds/InstalledDDC) && \
	rmdir /s /q C:/UnrealEngine/Engine

# Split out components (DDC, debug symbols, template projects) so they can be copied into the final container image as separate filesystem layers
COPY split-components.py C:/split-components.py
RUN python C:/split-components.py C:/UnrealEngine/LocalBuilds/Engine/Windows C:/UnrealEngine/Components

# Copy the Installed Build into a clean image, discarding the source tree
FROM vs AS minimal

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
