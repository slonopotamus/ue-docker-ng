FROM base as vs-prep

ARG repository
ADD $repository:Engine/Config/Windows C:/UnrealTemp

FROM base

RUN pip install json-with-comments
COPY --from=vs-prep C:/UnrealTemp/Windows_SDK.json C:/install-vs/Windows_SDK.json
COPY install-vs.py C:/install-vs/
RUN python C:/install-vs/install-vs.py C:/install-vs/Windows_SDK.json
