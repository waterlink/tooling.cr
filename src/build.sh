#!/usr/bin/env bash

set -ex

CRYSTAL_VERSION=$(cat ../../.crystal-version)
ARCH=$(arch)
LLVM_VERSION=3.5.0-1
LLVM_ARCH=linux-${ARCH}

if [[ -x ../../bin/crystal ]] && [[ "$(../../bin/crystal --version | awk '{print $2}' || echo oops)" = "$CRYSTAL_VERSION" ]]; then
  echo "crystal is up-to-date: nothing to do"
  exit 0
fi

export CRYSTAL_CONFIG_VERSION=$CRYSTAL_VERSION
export CRYSTAL_CONFIG_PATH=/opt/crystal/src:./libs
export LIBRARY_PATH=/opt/crystal/embedded/lib

mkdir -p .deps
[[ -d ./.deps/crystal ]] || git clone \
  --depth=1 \
  https://github.com/crystal-lang/crystal \
  -b $CRYSTAL_VERSION \
  .deps/crystal

[[ -d "./.deps/llvm-${LLVM_VERSION}" ]] || curl http://crystal-lang.s3.amazonaws.com/llvm/llvm-${LLVM_VERSION}-${LLVM_ARCH}.tar.gz | tar xz -C ./.deps

export PATH=$(pwd)/.deps/llvm-${LLVM_VERSION}/bin:$PATH

if [[ -x ../../bin/crystal ]]; then
  export PATH="$(pwd)/../../bin:$PATH"
fi

(cd .deps/crystal && make LLVM_CONFIG=../llvm-${LLVM_VERSION}/bin/llvm-config crystal)

mkdir -p ../../bin
cp ./.deps/crystal/.build/crystal ../../bin/
