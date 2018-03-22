require 'base64'

module Bump
  class CLI
    module Commands
      class Validate < Base
        desc "Validate a given file against its schema definition"
        argument :file, required: true, desc: "Path or URL to your API documentation file. Only OpenApi 2.0 (Swagger) specification is currently supported."
        option :id, default: ENV.fetch("BUMP_ID", ""), desc: "Documentation public id"
        option :token, default: ENV.fetch("BUMP_TOKEN", ""), desc: "Documentation private token"
        option :format, default: "yaml", values: %w[yaml json], desc: "Format of the definition"

        def call(file:, format:, id:, token:)
          with_errors_rescued do
            response = HTTP
              .headers(headers(token: token))
              .post(API_URL + "/docs/#{id}/validations", body: body(file, format).to_json)

            if response.code == 200
              puts "Definition is valid."
            else
              display_error(response)
            end
          end
        end

        private

        def body(file, format)
          {
            definition: open(file).read,
            format: format
          }
        end
      end
    end
  end
end
