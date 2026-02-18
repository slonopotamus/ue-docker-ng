#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

export DEBIAN_FRONTEND=noninteractive

apt-get update

# Install our build prerequisites
apt-get install -y --no-install-recommends \
		build-essential \
		ca-certificates \
		curl \
		git \
		git-lfs \
		gpg-agent \
		python3 \
		python3-dev \
		python3-pip \
		shared-mime-info \
		software-properties-common \
		sudo \
		tzdata \
		unzip \
		xdg-user-dirs \
		xdg-utils \
		zip

# Install the X11 runtime libraries required by CEF so we can cook Unreal Engine projects that use the WebBrowserWidget plugin
# (Starting in Unreal Engine 5.0, we need these installed before creating an Installed Build to prevent cooking failures related to loading the Quixel Bridge plugin)
apt-get install -y --no-install-recommends \
			libasound2 \
			libatk1.0-0 \
			libatk-bridge2.0-0 \
			libcairo2 \
			libfontconfig1 \
			libfreetype6 \
			libgbm1 \
			libglu1 \
			libnss3 \
			libnspr4 \
			libpango-1.0-0 \
			libpangocairo-1.0-0 \
			libsm6 \
			libxcomposite1 \
			libxcursor1 \
			libxdamage1 \
			libxi6 \
			libxkbcommon-x11-0 \
			libxrandr2 \
			libxrender1 \
			libxss1 \
			libxtst6 \
			libxv1 \
			x11-xkb-utils \
			xauth \
			xfonts-base \
			xkb-data

# Install the Avahi runtime libraries required by the NDIMedia plugin
# (Starting in Unreal Engine 5.7, we need these installed before creating an Installed Build to prevent cooking failures)
apt-get install -y --no-install-recommends \
			libavahi-client3

rm -rf /var/lib/apt/lists/*
