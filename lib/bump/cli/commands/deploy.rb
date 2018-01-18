require 'base64'

module Bump
  class CLI
    module Commands
      class Deploy < Base
        desc "Creates a new version"
        argument :authentication, required: true, desc: "Authentication string, following this format: DOC_ID:DOC_TOKEN."
        argument :file, required: true, desc: "Path or URL to your API documentation file. Only OpenApi 2.0 (Swagger) specification is currently supported."
        option :format, default: "yaml", values: %w[yaml json], desc: "Format of the definition"

        def call(**options)
          id, token = options.fetch(:authentication).split(':')
          response = HTTP.headers(headers(token)).post(API_URL + "/docs/#{id}/versions", body: body(options).to_json)

          if response.code == 201
            puts "New version has been successfuly deployed."
          elsif response.code == 204
            puts "Version was already deployed."
          else
            display_error(response)
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
