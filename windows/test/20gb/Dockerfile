FROM base AS intermediate
RUN fsutil file createnew C:\stuff\bigfile.txt 22548578304

FROM base
COPY --from=intermediate C:\stuff C:\stuff
