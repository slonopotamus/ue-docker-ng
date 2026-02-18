FROM source

# Remove the .git directory to disable UBT `git status` calls and speed up the build process
RUN if exist .git rmdir /s /q .git

# Set the changelist number in Build.version to ensure our Build ID is generated correctly
ARG changelist
COPY --from=common set-changelist.py C:/set-changelist.py
RUN python C:/set-changelist.py C:/UnrealEngine/Engine/Build/Build.version %changelist%

# Create an Installed Build of the Engine
ARG buildgraph_args
RUN Engine/Build/BatchFiles/RunUAT.bat BuildGraph \
	-target="Make Installed Build Win64" \
	-script=Engine/Build/InstalledEngineBuild.xml \
	-set:HostPlatformOnly=true \
	-set:WithClient=true \
	-set:WithDDC=false \
	-set:WithServer=true \
    %buildgraph_args% && \
	(if exist LocalBuilds/InstalledDDC rmdir /s /q LocalBuilds/InstalledDDC) && \
	rmdir /s /q Engine
