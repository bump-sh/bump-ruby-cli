module Bump
  class CLI
    module Commands
      class Preview < Base
        desc "Create a documentation preview for the given file"
        argument :file, required: true, desc: "Path or URL to your API documentation file. Only OpenApi 2.0 (Swagger) specification is currently supported."
        option :specification, default: 'openapi/v2/yaml', desc: "Specification of the definition"

        def call(file:, specification:)
          with_errors_rescued do
            response = HTTP
              .headers(headers)
              .post(API_URL + "/previews", body: body(file, specification).to_json)

            if response.code == 201
              body = JSON.parse(response.body)
              puts "Preview created : #{ROOT_URL + '/preview/' + body['id']} (expires at #{body['expires_at']})"
            else
              display_error(response)
            end
          end
        end
      end
    end
  end
end
