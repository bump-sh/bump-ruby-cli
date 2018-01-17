require 'open-uri'
require 'base64'

module Bump
  class CLI
    module Commands
      class Validate < Base
        desc "Validates a given file against its schema definition"
        argument :authentication, required: true, desc: "Authentication string, following this format: DOC_ID:DOC_TOKEN."
        argument :file, required: true, desc: "Path or URL to your API documentation file. Only OpenApi 2.0 (Swagger) specification is currently supported."
        option :format, default: "yaml", values: %w[yaml json], desc: "Format of the definition"

        def call(**options)
          id, token = options.fetch(:authentication).split(':')
          response = HTTP.headers(headers(token)).post(API_URL + "/docs/#{id}/validations", body: body(options).to_json)

          if response.code == 200
            puts "Definition is valid."
          elsif response.code == 422
            body = JSON.parse(response.body)
            display_invalid_definition(body)
          elsif response.code == 401
            display_generic_error("message" => "Invalid authentication string (status: 401)")
          else
            display_generic_error("message" => "Unknown error (status: #{response.code})")
          end
        rescue HTTP::Error => error
          display_http_error(error)
        end

        private

        def headers(token)
          default_headers.merge("Authorization" => "Basic #{Base64.strict_encode64(token + ':')}")
        end

        def body(options)
          {
            version: {
              definition: open(options.fetch(:file)).read,
              format: options.fetch(:format)
            }
          }
        end
      end
    end
  end
end
