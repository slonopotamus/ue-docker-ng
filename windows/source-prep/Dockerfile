FROM base

ARG repository=""
ADD --keep-git-dir=true $repository C:/UnrealEngine
RUN git -C C:/UnrealEngine lfs install && git -C C:/UnrealEngine lfs pull
