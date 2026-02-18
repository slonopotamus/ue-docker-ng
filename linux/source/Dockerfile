FROM base

ARG repository=""
ADD --keep-git-dir=true --chown=ue:ue $repository /home/ue/UnrealEngine

RUN /home/ue/UnrealEngine/Setup.sh -no-cache

# Set the changelist number in Build.version to ensure our Build ID is generated correctly
ARG changelist
COPY set-changelist.py /tmp/set-changelist.py
RUN python3 /tmp/set-changelist.py /home/ue/UnrealEngine/Engine/Build/Build.version $changelist

WORKDIR /home/ue/UnrealEngine
