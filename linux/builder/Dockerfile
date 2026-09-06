FROM source

COPY --from=shared BuildConfiguration.xml /home/ue/.config/UnrealEngine/UnrealBuildTool/

# Set the changelist number in Build.version to ensure our Build ID is generated correctly
COPY --from=shared set-changelist.py /tmp/set-changelist.py
ARG changelist=""
RUN python3 /tmp/set-changelist.py Engine/Build/Build.version $changelist

# Disable Nuget package auditing (warnings NU1902 and NU1903)
ENV NuGetAudit=false

RUN ./Engine/Build/BatchFiles/BuildUBT.sh

# I'd like to call Engine/Source/Programs/UnrealBuildAccelerator/Deploy-Linux.sh here, but it is just broken
RUN if [ -f Engine/Source/Programs/UnrealBuildAccelerator/UbaHost.Target.cs ]; then \
      ./Engine/Build/BatchFiles/RunUBT.sh -NoUba -NoUbaLocal UbaHost Linux Shipping \
    fi

# Create an Installed Build of the Engine
ARG buildgraph_args
RUN ./Engine/Build/BatchFiles/RunUAT.sh BuildGraph \
	-target="Make Installed Build Linux" \
	-script=Engine/Build/InstalledEngineBuild.xml \
    $buildgraph_args && \
	rm -R -f ./LocalBuilds/InstalledDDC

# Ensure UnrealVersionSelector is built, since the prebuilt binaries may not be up-to-date
RUN ./Engine/Build/BatchFiles/RunUBT.sh UnrealVersionSelector Linux Shipping

# Copy InstalledBuild.txt from the Installed Build and run UnrealVersionSelector to populate Install.ini with any custom Build ID specified in the BuildGraph flags
# (Note that the `-unattended` flag used below requires Unreal Engine 4.22 or newer, so this will break under older versions)
# (Note also that custom Build IDs are supported by Unreal Engine 5.3.1 and newer, and older versions will just use a GUID as the Build ID)
RUN cp LocalBuilds/Engine/Linux/Engine/Build/InstalledBuild.txt Engine/Build/InstalledBuild.txt && \
	./Engine/Binaries/Linux/UnrealVersionSelector-Linux-Shipping -register -unattended
