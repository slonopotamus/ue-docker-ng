FROM base

ARG repository
ADD --chown=ue:ue --keep-git-dir=true $repository /home/ue/UnrealEngine

WORKDIR /home/ue/UnrealEngine

ARG setup_args=""
RUN /home/ue/UnrealEngine/Setup.sh -no-cache $setup_args
