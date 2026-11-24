FROM source

COPY --from=shared ["BuildConfiguration.xml", "$WINEPREFIX/drive_c/users/ue/AppData/Roaming/Unreal Engine/UnrealBuildTool/"]

# Set the changelist number in Build.version
COPY --from=shared set-changelist.py /tmp/
ARG changelist=""
RUN python3 /tmp/set-changelist.py Engine/Build/Build.version "$changelist"

# Disable Nuget package auditing (warnings NU1902 and NU1903)
ENV NuGetAudit=false

RUN wine Engine/Build/BatchFiles/BuildUBT.bat

# Rebuild UbaHost in case engine modified its sources
# I'd like to call Engine/Source/Programs/UnrealBuildAccelerator/Deploy-Windows.bat here, but it is just broken
RUN if [ -f Engine/Source/Programs/UnrealBuildAccelerator/UbaHost.Target.cs ]; then \
    wine Engine/Build/BatchFiles/RunUBT.bat -NoUba -NoUbaLocal UbaHost Win64 Shipping; \
  fi

# Create an Installed Build of the Engine (building for Windows from source under Wine)
COPY --from=shared make-build-id-override.py /tmp/make-build-id-override.py
ARG buildgraph_args
RUN wine Engine/Build/BatchFiles/RunUAT.bat BuildGraph \
	-target="Make Installed Build Win64" \
	-script=Engine/Build/InstalledEngineBuild.xml \
    -set:BuildIdOverride="$(python3 /tmp/make-build-id-override.py Engine/Build/Build.version)" \
    $buildgraph_args && \
    rm -rf Engine
