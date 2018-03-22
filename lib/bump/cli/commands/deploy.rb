require 'base64'

module Bump
  class CLI
    module Commands
      class Deploy < Base
        desc "Create a new version"
        argument :file, required: true, desc: "Path or URL to your API documentation file. Only OpenApi 2.0 (Swagger) specification is currently supported."
        option :id, default: ENV.fetch("BUMP_ID", ""), desc: "Documentation public id"
        option :token, default: ENV.fetch("BUMP_TOKEN", ""), desc: "Documentation private token"
        option :format, default: "yaml", values: %w[yaml json], desc: "Format of the definition"

        def call(file:, format:, id:, token:)
          response = HTTP
            .headers(headers(token: token))
            .post(API_URL + "/docs/#{id}/versions", body: body(file, format).to_json)

          if response.code == 201
            puts "New version has been successfully deployed."
          elsif response.code == 204
            puts "Version was already deployed."
          else
            display_error(response)
          end
        rescue HTTP::Error => error
          display_http_error(error)
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
