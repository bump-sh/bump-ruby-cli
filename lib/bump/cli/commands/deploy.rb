require 'base64'

module Bump
  class CLI
    module Commands
      class Deploy < Base
        desc "Create a new version"
        argument :file, required: true, desc: "Path or URL to your API documentation file. OpenApi 2.0 and 3.0 specifications are currently supported."
        option :id, default: ENV.fetch("BUMP_ID", ""), desc: "Documentation public id"
        option :token, default: ENV.fetch("BUMP_TOKEN", ""), desc: "Documentation private token"
        option :specification, desc: "Specification of the definition"

        def call(file:, id:, token:, specification: nil)
          with_errors_rescued do
            response = post(
              url: API_URL + "/docs/#{id}/versions",
              body: body(file, specification).to_json,
              token: token
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
