require "bump/cli/version"
require "hanami/cli"

module Bump
  class CLI
    def call(*args)
      Hanami::CLI.new(Commands).call(*args)
    end

    module Commands
      extend Hanami::CLI::Registry
    end
  end
end
