require 'base64'

module Bump
  class CLI
    module Commands
      class Validate < Base
        desc "Validate a given file against its schema definition"
        argument :file, required: true, desc: "Path or URL to your API documentation file. OpenApi 2.0 and 3.0 specifications are currently supported."
        option :id, default: ENV.fetch("BUMP_ID", ""), desc: "Documentation public id"
        option :token, default: ENV.fetch("BUMP_TOKEN", ""), desc: "Documentation private token"
        option :specification, desc: "Specification of the definition"

        def call(file:, id:, token:, specification: nil)
          with_errors_rescued do
            response = post(
              url: API_URL + "/docs/#{id}/validations",
              body: body(file, specification).to_json,
              token: token
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
