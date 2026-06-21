FROM base

ARG repository=""
ADD --keep-git-dir=true $repository C:/UnrealEngine
RUN git lfs install && git lfs pull
