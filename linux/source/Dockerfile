FROM base

ARG repository=""
ADD --keep-git-dir=true --chown=ue:ue $repository /home/ue/UnrealEngine

RUN /home/ue/UnrealEngine/Setup.sh -no-cache --exclude=Android --exclude=Mac --exclude=Win32 --exclude=Win64

WORKDIR /home/ue/UnrealEngine
