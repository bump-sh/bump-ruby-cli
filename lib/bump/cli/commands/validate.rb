require 'base64'

module Bump
  class CLI
    module Commands
      class Validate < Base
        desc "Validate a given file against its schema definition"
        argument :file, required: true, desc: "Path or URL to your API documentation file. OpenAPI (2.0 to 3.0.2) and AsyncAPI (2.0) specifications are currently supported."
        option :documentation, default: ENV.fetch("BUMP_ID", ""), desc: "Documentation public id or slug"
        option :hub, desc: "Hub id or slug"
        option :token, default: ENV.fetch("BUMP_TOKEN", ""), desc: "Documentation or Hub token"
        option :specification, desc: "Specification of the definition"
        option :validation, desc: "Validation mode", values: %w(basic strict), default: 'basic'

        def call(file:, **options)
          with_errors_rescued do
            response = post(
              url: API_URL + "/validations",
              body: body(file, options).to_json,
              token: options[:token]
            )

            if response.code == 200
              puts "Definition is valid."
            else
              display_error(response)
            end
          end
        end
      end
    end
  end
end
