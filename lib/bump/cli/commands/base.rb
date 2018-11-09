require 'open-uri'

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

        def body(file, specification)
          {
            definition: open(file).read,
            specification: specification
          }
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
            display_invalid_definition(body)
          elsif response.code == 401
            abort "Invalid credentials (status: 401)"
          else
            body = JSON.parse(response.body)
            abort "Error : #{body["message"]} (status: #{response.code})"
          end
        rescue JSON::ParserError => e
          abort "Unknown error (status: #{response.code})"
        end

        def display_invalid_definition(body)
          puts "Definition is not valid:"
          body["errors"]["raw_definition"].each do |error|
            puts "> #{error}"
          end
          abort
        end
      end
    end
  end
end
