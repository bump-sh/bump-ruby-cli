# Bump::CLI

The `bump-cli` gem provides a simple command line access to the Bump (https://bump.sh) API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'bump-cli'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install bump-cli

## Usage

Bump tries to identify your file specification and format automatically. You can force it by using the `--specification` option. Here are the supported values:

* `openapi/v2/json`
* `openapi/v2/yaml`
* `openapi/v3/json`
* `openapi/v3/yaml`
* `asyncapi/v2/json`
* `asyncapi/v2/yaml`

`doc` and `token` options used below can be found in your documentation settings page on https://bump.sh. Note that you can replace the token option by an environment variable, to keep it secret: `--token` can by replaced by `BUMP_TOKEN`.

### Preview

You can preview your documentation by calling the `preview` command. A temporary preview will be created, with a unique URL. This preview will be available for 30 minutes. You don't need any credentials to use this command.

Preview a documentation:

    $ bundle exec bump preview path/to/your/file.yml

### Validate

Validate your file against its specification:

    $ bundle exec bump validate path/to/your/file.yml --doc DOC_ID_OR_SLUG --token DOC_TOKEN

### Deploy

Deploy the file as the current version of the documentation:

    $ bundle exec bump deploy path/to/your/file.yml --doc DOC_ID_OR_SLUG --token DOC_TOKEN

Automatically create a documentation inside a hub and deploy it:

    $ bundle exec bump deploy path/to/your/file.yml --auto-create --doc DOC_SLUG --hub HUB_ID_OR_SLUG --token HUB_TOKEN

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bump-sh/bump-cli. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Bump::CLI project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/bump-sh/bump-cli/blob/master/CODE_OF_CONDUCT.md).
