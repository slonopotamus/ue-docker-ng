FROM baseimage

ENV DEBIAN_FRONTEND=noninteractive

COPY --chmod=755 install-prerequisites.sh /tmp/
RUN --mount=type=cache,target=/var/cache/apt \
  --mount=type=cache,target=/var/lib/apt/lists \
  /tmp/install-prerequisites.sh

RUN useradd --create-home --home /home/ue --shell /bin/bash --uid 1000 ue && \
  passwd -d ue && \
  usermod -a -G audio,video,sudo ue
USER ue

# Enable Git Large File Storage (LFS) support
RUN git lfs install
