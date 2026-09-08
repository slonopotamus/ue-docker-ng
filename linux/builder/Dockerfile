FROM source

COPY --from=shared BuildConfiguration.xml /home/ue/.config/UnrealEngine/UnrealBuildTool/

# Set the changelist number in Build.version
COPY --from=shared set-changelist.py /tmp/
ARG changelist=""
RUN python3 /tmp/set-changelist.py Engine/Build/Build.version $changelist

# Disable Nuget package auditing (warnings NU1902 and NU1903)
ENV NuGetAudit=false

RUN ./Engine/Build/BatchFiles/BuildUBT.sh

# Rebuild UbaHost in case engine modified its sources
# I'd like to call Engine/Source/Programs/UnrealBuildAccelerator/Deploy-Linux.sh here, but it is just broken
RUN if [ -f Engine/Source/Programs/UnrealBuildAccelerator/UbaHost.Target.cs ]; then \
      ./Engine/Build/BatchFiles/RunUBT.sh -NoUba -NoUbaLocal UbaHost Linux Shipping; \
    fi

# Create an Installed Build of the Engine
COPY --from=shared make-build-id-override.py /tmp/make-build-id-override.py
ARG buildgraph_args
RUN ./Engine/Build/BatchFiles/RunUAT.sh BuildGraph \
	-target="Make Installed Build Linux" \
	-script=Engine/Build/InstalledEngineBuild.xml \
    -set:BuildIdOverride="$(python3 /tmp/make-build-id-override.py Engine/Build/Build.version)" \
    $buildgraph_args
