FROM base

ARG repository=""
ADD --keep-git-dir=true --chown=ue:ue $repository /home/ue/UnrealEngine

RUN /home/ue/UnrealEngine/Setup.sh -no-cache

WORKDIR /home/ue/UnrealEngine
