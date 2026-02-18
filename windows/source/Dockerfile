FROM base

# The git repository that we will clone
ARG GIT_REPO=""

# The git branch/tag/commit that we will checkout
ARG GIT_BRANCH=""

# Retrieve the address for the host that will supply git credentials
ARG HOST_ADDRESS_ARG=""
ENV HOST_ADDRESS=${HOST_ADDRESS_ARG}

# Retrieve the security token for communicating with the credential supplier
ARG HOST_TOKEN_ARG=""
ENV HOST_TOKEN=${HOST_TOKEN_ARG}

# Install our git credential helper that forwards requests to the host
COPY git-credential-helper.bat C:/git-credential-helper.bat
ENV GIT_ASKPASS=C:/git-credential-helper.bat
# See https://github.com/git-ecosystem/git-credential-manager/blob/main/docs/environment.md#GCM_INTERACTIVE
ENV GCM_INTERACTIVE=false

# Clone the UE4 git repository using the host-supplied credentials
WORKDIR C:/
RUN mkdir C:/UnrealEngine && \
	cd C:/UnrealEngine && \
	git init && \
	git remote add origin %GIT_REPO% && \
	git fetch --progress --depth 1 origin %GIT_BRANCH% && \
	git checkout FETCH_HEAD

ARG verbose

# Since the UE4 prerequisites installer appears to break when newer versions
# of the VC++ runtime are present, patch out the prereqs call in Setup.bat
COPY patch-setup-win.py C:/patch-setup-win.py
RUN python C:/patch-setup-win.py C:/UnrealEngine/Setup.bat ${verbose}

# Run post-clone setup steps
# (Note that the \-no-cache\ flag disables caching of dependency data in \.git/ue4-gitdeps\, saving disk space)
WORKDIR C:/UnrealEngine
RUN Setup.bat -no-cache {{ gitdependencies_args }}

# Set the changelist number in Build.version to ensure our Build ID is generated correctly
ARG CHANGELIST
COPY set-changelist.py C:/set-changelist.py
RUN python C:/set-changelist.py C:/UnrealEngine/Engine/Build/Build.version %CHANGELIST%
