require 'base64'

module Bump
  class CLI
    module Commands
      class Deploy < Base
        desc "Create a new version"
        argument :file, required: true, desc: "Path or URL to your API documentation file. OpenAPI (2.0 to 3.0.2) and AsyncAPI (2.0) specifications are currently supported."
        option :id, default: ENV.fetch("BUMP_ID", ""), desc: "Documentation public id"
        option :token, default: ENV.fetch("BUMP_TOKEN", ""), desc: "Documentation private token"
        option :specification, desc: "Specification of the definition"
        option :validation, desc: "Validation mode", values: %w(basic strict), default: 'basic'

        def call(file:, **options)
          with_errors_rescued do
            response = post(
              url: API_URL + "/versions",
              body: body(file, options).to_json,
              token: options[:token]
            )

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
