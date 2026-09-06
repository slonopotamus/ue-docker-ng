FROM source

COPY --from=shared ["BuildConfiguration.xml", "C:\\Users\\ContainerAdministrator\\AppData\\Roaming\\Unreal Engine\\UnrealBuildTool\\BuildConfiguration.xml"]

# Set the changelist number in Build.version to ensure our Build ID is generated correctly
COPY --from=shared ["set-changelist.py", "C:\\set-changelist.py"]
ARG changelist
RUN python C:/set-changelist.py C:/UnrealEngine/Engine/Build/Build.version %changelist%

# Disable Nuget package auditing (warnings NU1902 and NU1903)
ENV NuGetAudit=false

RUN Engine\Build\BatchFiles\BuildUBT.bat

# Rebuild UbaHost in case engine modified its sources
# I'd like to call Engine/Source/Programs/UnrealBuildAccelerator/Deploy-Windows.bat here, but it is just broken
RUN if exist Engine\Source\Programs\UnrealBuildAccelerator\UbaHost.Target.cs \
    Engine\Build\BatchFiles\RunUBT.bat -NoUba -NoUbaLocal UbaHost Win64 Shipping

# Create an Installed Build of the Engine
ARG buildgraph_args
RUN Engine\Build\BatchFiles\RunUAT.bat BuildGraph \
	-target="Make Installed Build Win64" \
	-script=Engine/Build/InstalledEngineBuild.xml \
    %buildgraph_args% && \
	(if exist LocalBuilds/InstalledDDC rmdir /s /q LocalBuilds/InstalledDDC) && \
	rmdir /s /q Engine
