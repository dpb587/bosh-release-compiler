#!/bin/bash -eu

set -eu -o pipefail

tar -xzf release/*.tgz $( tar -tzf release/*.tgz | grep release.MF$ )
release_name=$( grep '^name:' release.MF | awk '{print $2}' | tr -d "\"'" )
release_version=$( grep '^version:' release.MF | awk '{print $2}' | tr -d "\"'" )

tar -xzf stemcell/*.tgz stemcell.MF
stemcell_name=$( grep '^name:' stemcell.MF | awk '{print $2}' | tr -d "\"'" )
stemcell_os=$( grep '^operating_system:' stemcell.MF | awk '{print $2}' | tr -d "\"'" )
stemcell_version=$( grep '^version:' stemcell.MF | awk '{print $2}' | tr -d "\"'" )

export BOSH_DEPLOYMENT=$release_name-$release_version-on-$stemcell_os-stemcell-$stemcell_version

bosh upload-stemcell stemcell/*.tgz
bosh upload-release release/*.tgz

cat > deployment.yml <<EOF
name: "$BOSH_DEPLOYMENT"
instance_groups: []
releases:
- name: "$release_name"
  version: "$release_version"
stemcells:
- alias: "default"
  name: "$stemcell_name"
  version: "$stemcell_version"
update:
  canaries: 1
  canary_watch_time: 1
  max_in_flight: 1
  update_watch_time: 1
EOF

bosh -n deploy deployment.yml

bosh export-release "$release_name/$release_version" "$stemcell_os/$stemcell_version"

mv *.tgz compiled-release/$BOSH_DEPLOYMENT-compiled-1.$( date -u +%Y%m%d%H%M%S ).0.tgz

bosh -n delete-deployment
