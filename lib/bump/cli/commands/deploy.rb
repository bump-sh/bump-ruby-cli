require 'base64'

module Bump
  class CLI
    module Commands
      class Deploy < Base
        desc "Create a new version"
        argument :file, required: true, desc: "Path or URL to your API documentation file. Only OpenApi 2.0 (Swagger) specification is currently supported."
        option :id, default: ENV.fetch("BUMP_ID", ""), desc: "Documentation public id"
        option :token, default: ENV.fetch("BUMP_TOKEN", ""), desc: "Documentation private token"
        option :specification, default: 'openapi/v2/yaml', desc: "Specification of the definition"

        def call(file:, specification:, id:, token:)
          with_errors_rescued do
            response = HTTP
              .headers(headers(token: token))
              .post(API_URL + "/docs/#{id}/versions", body: body(file, specification).to_json)

            if response.code == 201
              puts "New version has been successfully deployed."
            elsif response.code == 204
              puts "Version was already deployed."
            else
              display_error(response)
            end
          end
        end
      end
    end
  end
end
