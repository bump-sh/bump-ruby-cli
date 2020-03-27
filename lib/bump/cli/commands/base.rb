require 'open-uri'
require 'bump/cli/tools/uuid'

module Bump
  class CLI
    module Commands
      class Base < Hanami::CLI::Command
        USER_AGENT = "bump-cli/#{VERSION}".freeze

        private

        def post(url:, body:, token: nil)
          HTTP
            .headers(headers(token: token))
            .post(url, body: body)
        end

        def body(file, **options)
          {
            definition: open(file).read,
            specification: options[:specification],
            validation: options[:validation],
            auto_create_documentation: options[:'auto-create']
          }.merge(documentation_or_hub(options)).compact
        end

        def documentation_or_hub(options)
          result = {}

          result[:documentation_id] = options[:documentation] if documentation_uuid?(options)
          result[:documentation_slug] = options[:documentation] if documentation_slug?(options)
          result[:hub_id] = options[:hub] if hub_uuid?(options)
          result[:hub_slug] = options[:hub] if hub_slug?(options)

          result
        end

        def documentation_uuid?(options)
          Bump::CLI::Tools::UUID.valid?(options[:documentation])
        end

        def documentation_slug?(options)
          !options[:documentation].nil? && !documentation_uuid?(options)
        end

        def hub_uuid?(options)
          Bump::CLI::Tools::UUID.valid?(options[:hub])
        end

        def hub_slug?(options)
          !options[:hub].nil? && !hub_uuid?(options)
        end

        def with_errors_rescued
          yield
        rescue HTTP::Error, Errno::ENOENT, SocketError => error
          abort "Error: #{error.message}"
        end

        def headers(token: '')
          headers = {
            'Content-Type' => 'application/json',
            'User-Agent' => USER_AGENT
          }

          if token
            headers['Authorization'] = "Basic #{Base64.strict_encode64(token + ':')}"
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
          errors = body.dig('errors') || []

          $stderr.puts "Invalid request:"
          errors.each do |attribute, messages|
            display_attribute_errors(attribute, messages)
          end

          abort
        end

        def display_attribute_errors(attribute, messages)
          case
          when messages.is_a?(String)
            $stderr.puts "- #{attribute}: #{messages}"
          when messages.is_a?(Array) && messages.count == 1
            $stderr.puts "- #{attribute}: #{messages[0]}"
          when messages.is_a?(Array)
            $stderr.puts "- #{attribute}:"
            messages.each do |message|
              $stderr.puts " #{message}"
            end
          end
        end
      end
    end
  end
end
