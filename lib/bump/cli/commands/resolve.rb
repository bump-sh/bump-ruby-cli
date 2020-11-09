module Bump
  class CLI
    module Commands
      class Resolve < Base
        desc "Resolve a specification external references"
        argument :file, required: true, desc: "Path or URL to your API documentation file. OpenAPI (2.0 to 3.0.2) and AsyncAPI (2.0) specifications are currently supported."
        argument :destination, required: false, desc: "Destination file if not the same."
        option :overwrite, type: :boolean, desc: "Overwrite the destination file if it already exists."

        def call(file:, destination: nil, **options)
          with_errors_rescued do
            definition = Definition.new(file, import_external_references: true)
            destination = destination.nil? ? file : destination
            check_destination!(destination, options)

            definition.prepare
            definition.write(to: destination)

            puts "External references have been resolved in #{destination}"
          end
        end

        def check_destination!(destination, options)
          if File.exists?(destination) && options[:overwrite] == false
            abort "Destination #{destination} already exists. Use --overwrite to overwrite it."
          end
        end
      end
    end
  end
end
