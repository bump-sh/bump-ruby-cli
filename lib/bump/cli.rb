require "bump/cli/version"
require "dry/cli"
require "http"

module Bump
  class CLI
    ROOT_URL = "https://bump.sh".freeze
    API_PATH = "/api/v1".freeze
    API_URL = ROOT_URL + API_PATH

    def call(*args)
      warn ":WARNING:"
      warn "  This Bump CLI is now legacy and will not be maintained any further."
      warn ""
      warn "  Please update to our new v2.x CLI available at https://github.com/bump-sh/cli"
      warn "  You can install the new Bump CLI with 'npm install -g bump-cli'"
      warn "                                     or 'yarn global add bump-cli'"
      warn ":WARNING:"
      warn ""
      Dry::CLI.new(Commands).call(*args)
    end

    module Commands
      extend Dry::CLI::Registry
    end
  end
end

require "bump/cli/commands/base"
require "bump/cli/commands/deploy"
require "bump/cli/commands/preview"
require "bump/cli/commands/validate"

Bump::CLI::Commands.register "deploy", Bump::CLI::Commands::Deploy
Bump::CLI::Commands.register "preview", Bump::CLI::Commands::Preview
Bump::CLI::Commands.register "validate", Bump::CLI::Commands::Validate
