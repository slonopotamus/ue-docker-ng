FROM source

# Remove the .git directory to disable UBT `git status` calls and speed up the build process
RUN if exist .git rmdir /s /q .git

# Set the changelist number in Build.version to ensure our Build ID is generated correctly
ARG changelist
COPY set-changelist.py C:/set-changelist.py
RUN python C:/set-changelist.py C:/UnrealEngine/Engine/Build/Build.version %changelist%

# Create an Installed Build of the Engine
RUN Engine/Build/BatchFiles/RunUAT.bat BuildGraph \
	-target="Make Installed Build Win64" \
	-script=Engine/Build/InstalledEngineBuild.xml \
	-set:HostPlatformOnly=true \
	-set:WithClient=true \
	-set:WithDDC=false \
	-set:WithServer=true && \
	(if exist LocalBuilds/InstalledDDC rmdir /s /q LocalBuilds/InstalledDDC) && \
	rmdir /s /q Engine

# Split out components (DDC, debug symbols, template projects) so they can be copied into the final container image as separate filesystem layers
COPY split-components.py C:/split-components.py
RUN python C:/split-components.py LocalBuilds/Engine/Windows Components
