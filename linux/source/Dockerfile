FROM base

ARG repository=""
ADD --keep-git-dir=true --chown=ue:ue $repository /home/ue/UnrealEngine
RUN git lfs istall && git lfs pull

ARG setup_args
# Run post-clone setup steps
# (Note that the \-no-cache\ flag disables caching of dependency data in \.git/ue4-gitdeps\, saving disk space)
RUN /home/ue/UnrealEngine/Setup.sh -no-cache $setup_args

WORKDIR /home/ue/UnrealEngine
