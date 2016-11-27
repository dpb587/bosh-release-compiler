#!/bin/sh -eu

set -eu -o pipefail

git clone file://$PWD/downloads downloads-output

cd bosh-release-compiler

source bin/target-bosh-director ../bosh-director

tar -xzf ../release/*.tgz $( tar -tzf ../release/*.tgz | grep release.MF$ )
release_name=$( grep '^name:' release.MF | awk '{print $2}' | tr -d "\"'" )
release_version=$( grep '^version:' release.MF | awk '{print $2}' | tr -d "\"'" )

tar -xzf ../stemcell/*.tgz stemcell.MF
stemcell_name=$( grep '^name:' stemcell.MF | awk '{print $2}' | tr -d "\"'" )
stemcell_os=$( grep '^operating_system:' stemcell.MF | awk '{print $2}' | tr -d "\"'" )
stemcell_version=$( grep '^version:' stemcell.MF | awk '{print $2}' | tr -d "\"'" )

export BOSH_DEPLOYMENT="$release_name-$release_version-on-$stemcell_os-stemcell-$stemcell_version"

bosh upload-stemcell ../stemcell/*.tgz
bosh upload-release ../release/*.tgz

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

fullname="$BOSH_DEPLOYMENT-compiled-1.$( date -u +%Y%m%d%H%M%S ).0.tgz"
mv *.tgz ../compiled-release/$BOSH_DEPLOYMENT.tgz

jq -n \
  --arg version "$release_version" \
  --arg download_prefix "$download_prefix" \
  --arg stemcell_os "$stemcell_os" \
  --arg stemcell_version "$stemcell_version" \
  --arg fullname "$fullname" \
  '
    {
      "metadata": [
        {
          "key": "stability",
          "value": "stable",
        },
        {
          "key": "type",
          "value": "bosh-compiled-release"
        },
        {
          "key": "stemcell_os",
          "value": $stemcell_os
        },
        {
          "key": "stemcell_version",
          "value": $stemcell_version
        },
        {
          "key": "version",
          "value": $version
        }
      ],
      "origin": [
        {
          "uri": "\($download_prefix)\($fullname)"
        }
      ]
    }
  ' \
  | ./bin/commit-download ../compiled-release/$BOSH_DEPLOYMENT.tgz ../downloads-output

mv ../compiled-release/$BOSH_DEPLOYMENT.tgz ../compiled-release/$fullname
