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

bosh -n clean-up --all

set +u

source /etc/profile.d/chruby.sh

chruby 2.3.1

bosh delete-env "/tmp/local-bosh/director/bosh-director.yml" \
  --vars-store="/tmp/local-bosh/director/creds.yml" \
  --state="/tmp/local-bosh/director/state.json"
