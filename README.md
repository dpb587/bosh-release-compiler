# bosh-release-compiler

A pipeline for pre-compiling releases when new versions or stemcells are published.


## Usage

    $ cp vars.default.yml vars.yml
    $ vim vars.yml
    $ fly set-pipeline -p my-release-compiler -c <( bosh interpolate --vars-file vars.default.yml --vars-file vars.yml pipeline.yml )


## Docker

    cd images/main
    docker build -t dpb587/bosh-release-compiler:main .
    docker push dpb587/bosh-release-compiler:main


## License

[MIT License](./LICENSE)
