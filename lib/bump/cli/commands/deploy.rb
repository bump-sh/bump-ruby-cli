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
          authentication = authentication_service(options)
          response = HTTP.headers(headers(authentication)).post(API_URL + "/docs/#{authentication.id}/versions", body: body(options).to_json)

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

        def headers(authentication)
          default_headers.merge(authentication.as_headers)
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
