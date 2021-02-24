require "base64"

module Bump
  class CLI
    module Commands
      class Deploy < Base
        desc "Create a new version"
        argument :file, required: true, desc: "Path or URL to your API documentation file. OpenAPI (2.0 to 3.0.2) and AsyncAPI (2.0) specifications are currently supported."
        option :id, default: ENV.fetch("BUMP_ID", ""), desc: "[DEPRECATED] Documentation id. Use the `--doc` option instead"
        option :doc, default: ENV.fetch("BUMP_ID", ""), desc: "Documentation id or slug"
        option :'doc-name', desc: "Documentation name. Used with --auto-create flag."
        option :hub, default: ENV.fetch("BUMP_HUB_ID", ""), desc: "Hub id or slug"
        option :token, default: ENV.fetch("BUMP_TOKEN", ""), desc: "Documentation or Hub token"
        option :specification, desc: "Specification of the definition"
        option :validation, desc: "Validation mode", values: %w[basic strict], default: "basic"
        option :'auto-create', type: :boolean, default: false, desc: "Automatically create the documentation if needed (only available with a hub and when specifying a slug for documentation)"
        option :'no-external-references', type: :boolean, default: false, desc: "Do not import external references ($ref)"
        option :'import-external-references', type: :boolean, default: false, desc: "[DEPRECATED] External references are imported by default"

        def call(file:, **options)
          with_errors_rescued do
            response = post(
              url: API_URL + "/versions",
              body: body(file, **options).to_json,
              token: options[:token]
            )

            if response.code == 201
              puts "The new version is currently being processed."
            elsif response.code == 204
              puts "This version has already been deployed."
            else
              display_error(response)
            end
          end
        end
      end
    end
  end
end
