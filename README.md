# Ldflow

## Prerequisites

* ruby 3.2+

## Installation

1. Clone the repository

   Clone the repository and submodules at once by

   ```shell
   git clone --recurse-submodules https://github.com/dbcls/ldflow.git
   ```
   
   or step by step

   ```shell
   git clone https://github.com/dbcls/ldflow.git
   cd ldflow
   git submodule update --init
   ```

2. Install executable

   ```shell
   cd ldflow
   rake install
   ldflow version
   ```

## Usage

```shell
ldflow help
```

```plain
Commands:
  ldflow convert         # Subcommands for file format conversion
  ldflow help [COMMAND]  # Describe available commands or one specific command
  ldflow version         # Show version number
```

### `convert jsonl`

Convert JSON-LD lines to other RDF formats

```plain
Usage:
  ldflow convert jsonl <FILE>

Options:
  -f, [--format=FORMAT]    # Output format
                           # Default: ntriples
                           # Possible values: ntriples
  -l, [--lines=N]          # Number of lines per batch
                           # Default: 10000
  -p, [--max-proc=N]       # Maximum number of processes
                           # Default: 1
  -o, [--output=OUTPUT]    # Path to the output
                           # Default: -
      [--preload=PRELOAD]  # Path to a context file to preload
```

### `convert table`

Convert table format data to RDF with RDF Config

```plain
Usage:
  ldflow convert table <FILE> -c, --config-dir=CONFIG_DIR

Options:
  -c, --config-dir=CONFIG_DIR  # Path to config directory
  -f, [--format=FORMAT]        # Output format
                               # Default: jsonl
                               # Possible values: jsonld, json-ld, json_ld, jsonl, rdf
  -L, [--header-lines=N]       # Number of header lines
                               # Default: 1
  -l, [--lines=N]              # Number of lines per batch
                               # Default: 100
  -p, [--max-proc=N]           # Maximum number of processes
                               # Default: 1
  -o, [--output=OUTPUT]        # Path to the output
                               # Default: -
```

## Update `rdf-config` submodule

1. With an account that can push to GitHub

    ```shell
    cd path/to/ldflow
    git pull origin main
    cd vendor/rdf-config
    git pull origin master
    cd ../..
    git add vendor/rdf-config
    git commit -m 'update rdf-config'
    git push origin main
    ```

2. On the server in the execution environment

    ```shell
    cd path/to/ldflow
    git pull origin main
    git submodule update
    ```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/dbcls/ldflow. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/dbcls/ldflow/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Ldflow project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/dbcls/ldflow/blob/main/CODE_OF_CONDUCT.md).
