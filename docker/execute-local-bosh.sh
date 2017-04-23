#!/bin/bash

set -eu -o pipefail ; export SHELLOPTS

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )/.."

release_dir="$1"; shift
stemcell_dir="$1" ; shift
compiled_release_dir="$1" ; shift

mkdir -p "$compiled_release_dir"

docker run -t -i \
  --rm \
  --privileged \
  --volume="$DIR":/tmp/build/release-compiler:ro \
  --volume="$release_dir":/tmp/build/release:ro \
  --volume="$stemcell_dir":/tmp/build/stemcell:ro \
  --volume="$compiled_release_dir":/tmp/build/compiled-release \
  --workdir=/tmp/build \
  "$@" \
  bosh/main-bosh-docker:latest \
  release-compiler/execute-local-bosh.sh
