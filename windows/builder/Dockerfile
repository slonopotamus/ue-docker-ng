FROM source-with-vs

# Remove the .git directory to disable UBT `git status` calls and speed up the build process
RUN if exist C:/UnrealEngine/.git rmdir /s /q C:/UnrealEngine/.git

# Create an Installed Build of the Engine
RUN C:/UnrealEngine/Engine/Build/BatchFiles/RunUAT.bat BuildGraph \
	-target="Make Installed Build Win64" \
	-script=Engine/Build/InstalledEngineBuild.xml \
	-set:HostPlatformOnly=true \
	-set:WithClient=true \
	-set:WithDDC=false \
	-set:WithServer=true && \
	(if exist C:/UnrealEngine/LocalBuilds/InstalledDDC rmdir /s /q C:/UnrealEngine/LocalBuilds/InstalledDDC) && \
	rmdir /s /q C:/UnrealEngine/Engine

# Split out components (DDC, debug symbols, template projects) so they can be copied into the final container image as separate filesystem layers
COPY split-components.py C:/split-components.py
RUN python C:/split-components.py C:/UnrealEngine/LocalBuilds/Engine/Windows C:/UnrealEngine/Components
