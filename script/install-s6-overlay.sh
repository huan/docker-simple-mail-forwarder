#!/usr/bin/env bash

set -eo pipefail

if [[ -n "$1" ]]; then
  S6_VERSION=$1; shift
else
  echo "arg 1 should be the s6 version"
  exit 1
fi

case $(uname -m) in
  armv6l)
    # fall through
    ;&
  armv7l)
    ARCH=armhf
    ;;
  aarch64 | armv8l)
    ARCH=arm
    ;;
  i386)
    ARCH=x86
    ;;
  x86_64)
    ARCH=amd64
    ;;
  *)
    echo "ARCH not supported: $ARCH"
    exit 1
    ;;
esac

URL="https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-${ARCH}.tar.gz"

curl -L -s https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-amd64.tar.gz \
  | tar xzf - -C /
