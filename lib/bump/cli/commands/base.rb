require "bump/cli/definition"
require "bump/cli/uuid"

module Bump
  class CLI
    module Commands
      class Base < Dry::CLI::Command
        USER_AGENT = "bump-cli/#{VERSION}".freeze

        private

        def post(url:, body:, token: nil)
          HTTP
            .headers(headers(token: token))
            .post(url, body: body)
        end

        def body(file, **options)
          deprecation_warning(options)

          definition = Definition.new(file, import_external_references: !options[:'no-external-references'])
          definition.prepare!

          compact(
            {
              definition: definition.content,
              references: prepare_references(definition.external_references),
              specification: options[:specification],
              validation: options[:validation],
              auto_create_documentation: options[:'auto-create']
            }.merge(documentation_or_hub(options))
          )
        end

        def prepare_references(references)
          references.reduce([]) { |references, (location, content)|
            references << {location: location, content: content}
          }
        end

        def deprecation_warning(options)
          if options[:"import-external-references"]
            puts "[DEPRECATION WARNING] --import-external-references option is deprecated. External references are imported by default."
          end
        end

        def compact(hash)
          hash.delete_if { |key, value| value.nil? }
        end

        def documentation_or_hub(options)
          result = {}

          result[:documentation_id] = options[:id]
          result[:documentation_id] = options[:doc] if documentation_uuid?(options)
          result[:documentation_slug] = options[:doc] if documentation_slug?(options)
          result[:documentation_name] = options[:'doc-name']
          result[:hub_id] = options[:hub] if hub_uuid?(options)
          result[:hub_slug] = options[:hub] if hub_slug?(options)

          compact(result)
        end

        def documentation_uuid?(options)
          Bump::CLI::UUID.valid?(options[:doc])
        end

        def documentation_slug?(options)
          !options[:doc].nil? && !documentation_uuid?(options)
        end

        def hub_uuid?(options)
          Bump::CLI::UUID.valid?(options[:hub])
        end

        def hub_slug?(options)
          !options[:hub].nil? && !hub_uuid?(options)
        end

        def with_errors_rescued
          yield
        rescue HTTP::Error, Errno::ENOENT, SocketError => error
          abort "Error: #{error.message}"
        rescue => error
          warn "An unexpected error occurred. Sorry about that!"
          warn "We don't monitor errors raised by the CLI running on your computer, so we have not been notified."
          warn "You can help us fix this by creating an issue on https://github.com/bump-sh/bump-cli/issues/new?template=cli-runtime-error.md."
          warn "\n"
          warn "#{error.class}: #{error.message}"
          warn error.backtrace.take(10).join("\n")
          exit(1)
        end

        def headers(token: "")
          headers = {
            "Content-Type" => "application/json",
            "User-Agent" => USER_AGENT
          }

          if token
            headers["Authorization"] = "Basic #{Base64.strict_encode64(token + ":")}"
          end

          headers
        end

        def display_error(response)
          if response.code == 422
            body = JSON.parse(response.body)
            display_validation_errors(body)
          elsif response.code == 401
            abort "Invalid credentials (status: 401)"
          else
            body = JSON.parse(response.body)
            abort "Error : #{body["message"]} (status: #{response.code})"
          end
        rescue JSON::ParserError => e
          abort "Unknown error (status: #{response.code})"
        end

        def display_validation_errors(body)
          errors = body.dig("errors") || []

          warn "Invalid request:"
          errors.each do |attribute, messages|
            display_attribute_errors(attribute, messages)
          end

          abort
        end

        def display_attribute_errors(attribute, messages)
          if messages.is_a?(String)
            warn "- #{attribute}: #{messages}"
          elsif messages.is_a?(Array) && messages.count == 1
            warn "- #{attribute}: #{messages[0]}"
          elsif messages.is_a?(Array)
            warn "- #{attribute}:"
            messages.each do |message|
              warn " #{message}"
            end
          end
        end
      end
    end
  end
end
