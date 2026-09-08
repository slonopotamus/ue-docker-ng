FROM source

COPY --from=shared ["BuildConfiguration.xml", "C:/Users/ContainerAdministrator/AppData/Roaming/Unreal Engine/UnrealBuildTool/"]

# Set the changelist number in Build.version
COPY --from=shared set-changelist.py C:/
ARG changelist=""
RUN python C:\set-changelist.py C:/UnrealEngine/Engine/Build/Build.version %changelist%

# Disable Nuget package auditing (warnings NU1902 and NU1903)
ENV NuGetAudit=false

RUN Engine\Build\BatchFiles\BuildUBT.bat

# Rebuild UbaHost in case engine modified its sources
# I'd like to call Engine/Source/Programs/UnrealBuildAccelerator/Deploy-Windows.bat here, but it is just broken
RUN if exist Engine\Source\Programs\UnrealBuildAccelerator\UbaHost.Target.cs \
    Engine\Build\BatchFiles\RunUBT.bat -NoUba -NoUbaLocal UbaHost Win64 Shipping

# Create an Installed Build of the Engine
COPY --from=shared make-build-id-override.py C:/
ARG buildgraph_args
RUN for /f "delims=" %i in ('python C:\make-build-id-override.py C:\UnrealEngine\Engine\Build\Build.version') do set BuildIdOverride=%i&& \
	call Engine\Build\BatchFiles\RunUAT.bat BuildGraph \
		-target="Make Installed Build Win64" \
		-script=Engine/Build/InstalledEngineBuild.xml \
		-set:BuildIdOverride="%BuildIdOverride%" \
		%buildgraph_args% && \
	rmdir /s /q Engine
