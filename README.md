# bosh-release-compiler

For compiling a [BOSH](https://bosh.io/) release.


## Example


## Concourse

The [Concourse](https://concourse.ci/) task are in [`concourse/`](concourse) and utilize the following resources:

 * `release-compiler` input is this repository
 * `release` input contains a release tarball
 * `stemcell` input contains a stemcell tarball
 * `compiled-release` output will contain the compiled release tarball

To compile in a containerized BOSH, a job plan might look like...

    - aggregate:
      - get: release-compiler
      - get: release
      - get: stemcell
    - task: compile-release
      config: release-compiler/concourse/execute-local-bosh.yml
      privileged: true
    - put: compiled-release
      params:
        path: compiled-release/\*.tgz

To compile using an external BOSH, the task might look like...

    task: compile-release
    config: release-compiler/concourse/execute.yml
    params:
      BOSH_CA_CERT: |
        -----BEGIN CERTIFICATE-----
        MIIDFDCCAfygAwIBAgIRAIEONPtKG/t97vyf4eAvosUwDQYJKoZIhvcNAQELBQAw
        ...snip...
        -----END CERTIFICATE-----
      BOSH_CLIENT: release-compiler
      BOSH_CLIENT_SECRET: some-password
      BOSH_ENVIRONMENT: https://bosh.example.com:25555


## Docker

To compile using an external BOSH, with [Docker](https://docker.io/) you can execute...

    $ release-compiler/docker/execute.sh RELEASE_DIR STEMCELL_DIR COMPILED_RELEASE_DIR

With the following environment...

 * `RELEASE_DIR` directory contains a release tarball
 * `STEMCELL_DIR` directory contains a stemcell tarball
 * `COMPILED_RELEASE_DIR` directory will contain the compiled release tarball
 * `BOSH_ENVIRONMENT`, `BOSH_CA_CERT` variables refers to the director endpoint
 * `BOSH_CLIENT`, `BOSH_CLIENT_SECRET` variables provide authentication details


## Notes

 * Compiled release tarballs are named like `{release_name}-{release_version}-on-{stemcell_os}-stemcell-{stemcell_version}-compiled-1.{timestamp:%Y%m%d%H%M%S}.0.tgz`


## License

[MIT License](./LICENSE)
