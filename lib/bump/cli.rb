require "bump/cli/version"
require "hanami/cli"
require "http"

module Bump
  class CLI
    ROOT_URL = "https://bump.sh".freeze
    API_PATH = "/api/v1".freeze
    API_URL = ROOT_URL + API_PATH

    def call(*args)
      Hanami::CLI.new(Commands).call(*args)
    end

    module Commands
      extend Hanami::CLI::Registry
    end
  end
end

require "bump/cli/commands/base"
require "bump/cli/commands/preview"

Bump::CLI::Commands.register "preview", Bump::CLI::Commands::Preview
