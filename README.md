# Data Extractor

## Requirements
These utils need to be installed for gem to work
`poppler-utils`, `imagemagick`

## Installation
To install gem locally

```console
$ cd app
$ gem build
$ gem install data_extractor-0-0-0.gem
$ bundle install
```

A docker file can be used to build a standalone utility
`docker build -t data_extractor ./app`

## Usage
In ruby
```ruby
require 'data_extractor'

DataExtractor.new(filepath: 'somefile.pdf', operation: 'all')
```


Can be used via a `./app/bin/data_extractor` script
```console
$ ./app/bin/data_extractor --help
Usage: data_extractor [options]
    -f FILEPATH                      Input .pdf|.png file
    -c OPERATION                     Parse mode (all|text|preview)
    -o DIRPATH                       Output directory path
    -h, --help                       Help
```

To use docker you need to mount a volume with input and output directories. `-o` option is useful to specify output folder
Examples:
```console
# Run program for `input/example.pdf` file and output result in `input` folder
$ docker run -v ./input:/input/ --rm -it data_extractor -f /input/example.pdf -c text -o /input/

# To run Rspec spec
$ docker run -v --rm --entrypoint=rspec -it data_extractor

# For easy development from inside of the container. This will also result in a `app.log` file for you to inspect locally
$ docker run -v ./app/:/app -v ./input:/input --rm --entrypoint=bash -it data_extractor
```