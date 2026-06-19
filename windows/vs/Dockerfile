FROM base

RUN pip install json-with-comments
COPY --from=source-prep C:/UnrealEngine/Engine/Config/Windows/Windows_SDK.json C:/install-vs/
COPY install-vs.py C:/install-vs/
RUN python C:/install-vs/install-vs.py C:/install-vs/Windows_SDK.json
