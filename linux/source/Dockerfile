FROM base

ARG repository
ADD --chown=ue:ue --keep-git-dir=true $repository /home/ue/UnrealEngine

WORKDIR /home/ue/UnrealEngine

ARG setup_args=""
RUN --mount=type=cache,target=/home/ue/UnrealEngine/.git/ue-gitdeps,uid=1001,gid=1001 \
  --mount=type=cache,target=/home/ue/UnrealEngine/.git/ue4-sdks,uid=1001,gid=1001 \
  ./Setup.sh $setup_args
