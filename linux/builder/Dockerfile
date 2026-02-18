FROM source

# Remove the .git directory to disable UBT `git status` calls and speed up the build process
RUN rm -rf .git

# Ensure UBT is built before we create the Installed Build, since Build.sh explicitly sets the
# target .NET Framework version, whereas InstalledEngineBuild.xml just uses the system default,
# which can result in errors when running the built UBT due to the wrong version being targeted
RUN ./Engine/Build/BatchFiles/BuildUBT.sh

# Create an Installed Build of the Engine
RUN ./Engine/Build/BatchFiles/RunUAT.sh BuildGraph \
	-target="Make Installed Build Linux" \
	-script=Engine/Build/InstalledEngineBuild.xml \
	-set:HostPlatformOnly=true \
	-set:WithClient=true \
	-set:WithDDC=false \
	-set:WithServer=true && \
	rm -R -f ./LocalBuilds/InstalledDDC

# Ensure UnrealVersionSelector is built, since the prebuilt binaries may not be up-to-date
RUN ./Engine/Build/BatchFiles/Linux/Build.sh UnrealVersionSelector Linux Shipping

# Copy InstalledBuild.txt from the Installed Build and run UnrealVersionSelector to populate Install.ini with any custom Build ID specified in the BuildGraph flags
# (Note that the `-unattended` flag used below requires Unreal Engine 4.22 or newer, so this will break under older versions)
# (Note also that custom Build IDs are supported by Unreal Engine 5.3.1 and newer, and older versions will just use a GUID as the Build ID)
RUN cp LocalBuilds/Engine/Linux/Engine/Build/InstalledBuild.txt Engine/Build/InstalledBuild.txt && \
	./Engine/Binaries/Linux/UnrealVersionSelector-Linux-Shipping -register -unattended

# Split out both optional components (DDC, debug symbols, template projects) and large subdirectories so they can be copied
# into the final container image as separate filesystem layers, avoiding creating a single monolithic layer with everything
COPY split-components.py /tmp/split-components.py
RUN python3 /tmp/split-components.py LocalBuilds/Engine/Linux Components
