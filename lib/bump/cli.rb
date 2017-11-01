require "bump/cli/version"
require "hanami/cli"

module Bump
  class CLI
    def call(*args)
      Hanami::CLI.new(Commands).call(*args)
    end

    module Commands
      extend Hanami::CLI::Registry

      class Validate < Hanami::CLI::Command
        desc "Validate API documentation file"

        def call(*)
          puts "Validating..."
        end
      end

      class Deploy < Hanami::CLI::Command
        desc "Deploy the latest API version docs"

        def call(*)
          puts "Deploying..."
        end
      end
    end
  end
end

Bump::CLI::Commands.register "validate", Bump::CLI::Commands::Validate
Bump::CLI::Commands.register "deploy",   Bump::CLI::Commands::Deploy
