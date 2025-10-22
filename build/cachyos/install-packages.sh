#!/bin/bash

export TARGET

set -euo pipefail

# Update and install packages
pacman -Syu --noconfirm

# Install packages
pacman -S --noconfirm \
  imagemagick \
  file \
  sudo \
  net-tools \
  iputils \
  curl \
  git \
  jq \
  dos2unix \
  mariadb-clients \
  tzdata \
  rsync \
  nano \
  unzip \
  zstd \
  lbzip2 \
  nfs-utils \
  libpcap \
  git-lfs \
  jre21-openjdk-headless \
  ${EXTRA_ARCH_PACKAGES}

# Pre-install dependencies for gosu AUR
pacman -S --noconfirm go fakeroot base-devel git

# Create temporary build user
useradd -m build
mkdir -p /tmp/gosu && chown -R build:build /tmp/gosu

# Build the package as build user
sudo -u build bash <<'EOF'
cd /tmp/gosu
git clone --branch gosu --single-branch https://github.com/archlinux/aur.git .
makepkg --noconfirm --noprogressbar
EOF

# Install the resulting package as root
pacman -U --noconfirm /tmp/gosu/*.pkg.tar.zst

# Cleanup
rm -rf /tmp/gosu
userdel -r build

# Clean up
pacman -Scc --noconfirm

# Download and install patched knockd
curl -fsSL -o /tmp/knock.tar.gz https://github.com/Metalcape/knock/releases/download/0.8.1/knock-0.8.1-$TARGET.tar.gz
tar -xf /tmp/knock.tar.gz -C /usr/local/ && rm /tmp/knock.tar.gz
ln -s /usr/local/sbin/knockd /usr/sbin/knockd
setcap cap_net_raw=ep /usr/local/sbin/knockd

# Set git credentials globally
cat <<EOF >> /etc/gitconfig
[user]
	name = Minecraft Server on Docker
	email = server@example.com
EOF
