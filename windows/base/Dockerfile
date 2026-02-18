FROM baseimage

# Enable long path support
RUN reg add HKEY_LOCAL_MACHINE/SYSTEM/CurrentControlSet/Control/FileSystem /v LongPathsEnabled /t REG_DWORD /d 1 /f

# Install Chocolatey
RUN powershell -NoProfile -ExecutionPolicy Bypass -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))"

# Install the rest of our build prerequisites and clean up afterwards to minimise image size
COPY --link install-prerequisites.ps1 C:/
RUN powershell -ExecutionPolicy Bypass -File C:/install-prerequisites.ps1
