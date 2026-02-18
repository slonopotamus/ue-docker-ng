FROM base

RUN pip install json-with-comments
# TODO: Rework this. If Windows_SDK.json is missing, generate it on previous stage. So the only file that VS installation depends on is Windows_SDK.json and we don't reinstall VS when other files change
# Only copy files required to determine Visual Studio version to avoid reinstalling it when minor engine changes happen
COPY --from=source-prep C:/UnrealEngine/Engine/Config/Windows C:/install-vs/
COPY --from=source-prep C:/UnrealEngine/Engine/Build/Build.version C:/install-vs/
COPY install-vs.py C:/install-vs/
RUN python C:/install-vs/install-vs.py C:/install-vs/Windows_SDK.json C:/install-vs/Build.Version
