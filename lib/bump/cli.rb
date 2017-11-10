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

      class Version < Hanami::CLI::Command
        desc "Create a new version for a given documentation, which will become the current version"
        option :file, desc: "Path to your API documentation file. Only OpenApi 2.0 (Swagger) format is supported currently"
        options :format, default: "yml", values: %w[yml json], desc: "Format of the definition"

        def call(**options)
          headers = {
            "Content-Type" => "application/json",
            "Authorization" => "Token token=#{ENV.fetch("BUMP_TOKEN")}"
          }

          body = {
            version: {
              definition: File.read(options.fetch(:file)),
              format: options.fetch(:format)
            }
          }

          response = HTTP.headers(headers).post(BUMP_URL, body: body)

          if response.code == "204"
            puts "Documentation updated."
          else
            abort "An error occurred."
          end
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
