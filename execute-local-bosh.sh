#!/bin/bash

set -eu -o pipefail

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

start-bosh

source /tmp/local-bosh/director/env

bosh -n update-cloud-config \
  <( set -eu -o pipefail ; export SHELLOPTS

    bosh cloud-config \
      | sed "s/workers: .+/workers: $( grep -c ^processor /proc/cpuinfo )/"
  )

"$DIR/execute.sh"
