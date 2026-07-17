FROM base

ENV DEBIAN_FRONTEND=noninteractive

COPY --chmod=0755 install-prerequisites.sh /tmp/
RUN --mount=type=cache,sharing=locked,target=/var/cache/apt \
  --mount=type=cache,sharing=locked,target=/var/lib/apt/lists \
  /tmp/install-prerequisites.sh

RUN useradd --create-home --home /home/ue --shell /bin/bash --uid 1001 ue && \
  passwd -d ue && \
  usermod -a -G audio,video,sudo ue
USER ue

# Enable Git Large File Storage (LFS) support
RUN git lfs install
