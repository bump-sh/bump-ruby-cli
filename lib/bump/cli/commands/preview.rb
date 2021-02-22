module Bump
  class CLI
    module Commands
      class Preview < Base
        desc "Create a documentation preview for the given file"
        argument :file, required: true, desc: "Path or URL to your API documentation file. OpenAPI (2.0 to 3.0.2) and AsyncAPI (2.0) specifications are currently supported."
        option :specification, desc: "Specification of the definition"
        option :validation, desc: "Validation mode", values: %w[basic strict], default: "basic"
        option :'import-external-references', type: :boolean, default: false, desc: "Import external $refs (URI or file system) into the specification before sending it to Bump servers"

        def call(file:, **options)
          with_errors_rescued do
            response = post(
              url: API_URL + "/previews",
              body: body(file, **options).to_json
            )

            if response.code == 201
              body = JSON.parse(response.body)
              puts "Preview created : #{ROOT_URL + "/preview/" + body["id"]} (expires at #{body["expires_at"]})"
            else
              display_error(response)
            end
          end
        end
      end
    end
  end
end
