FROM baseimage

COPY --link --chmod=755 install-prerequisites.sh /tmp/
RUN /tmp/install-prerequisites.sh

RUN useradd --create-home --home /home/ue --shell /bin/bash --uid 1000 ue && \
  passwd -d ue && \
  usermod -a -G audio,video,sudo ue
USER ue

# Enable Git Large File Storage (LFS) support
RUN git lfs install
