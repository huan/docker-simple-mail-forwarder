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
    ;& # fall through
  armv7l)
    ARCH=armhf
    ;;
  armv8l)
    ARCH=arm
    ;;
  aarch64)
    ARCH=aarch64
    ;;
  i386)
    ARCH=x86
    ;;
  x86_64)
    ARCH=x86_64
    ;;
  *)
    echo "ARCH not supported: $ARCH"
    exit 1
    ;;
esac

URL="https://github.com/just-containers/s6-overlay/releases/download/v${S6_VERSION}/s6-overlay-${ARCH}.tar.xz"
curl -L -s $URL \
  | tar -xJf - -C /
