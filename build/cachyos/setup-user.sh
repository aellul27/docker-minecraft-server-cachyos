#!/bin/sh

set -e
groupadd -g 1000 minecraft
useradd --system --shell /bin/false --uid 1000 -g minecraft --home /data minecraft
