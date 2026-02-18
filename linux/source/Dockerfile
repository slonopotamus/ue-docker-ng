FROM base

ARG repository=""
ADD --keep-git-dir=true --chown=ue:ue $repository /home/ue/UnrealEngine

ENV UE_GITDEPS=/home/ue/gitdeps
ARG setup_args
RUN --mount=type=cache,target=/home/ue/gitdeps,uid=1000,gid=1000 /home/ue/UnrealEngine/Setup.sh $setup_args

WORKDIR /home/ue/UnrealEngine
