FROM base

ARG repository
ADD --chown=ue:ue --keep-git-dir=true $repository /home/ue/UnrealEngine

WORKDIR /home/ue/UnrealEngine

ARG setup_args=""
RUN --mount=type=cache,target=/home/ue/UnrealEngine/.git/ue-gitdeps,uid=1000,gid=1000 \
  --mount=type=cache,target=/home/ue/UnrealEngine/.git/ue4-sdks,uid=1000,gid=1000 \
  ./Setup.sh $setup_args
