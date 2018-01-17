require 'open-uri'

module Bump
  class CLI
    module Commands
      class Preview < Hanami::CLI::Command
        desc "Create a documentation preview for the given file"
        argument :file, required: true, desc: "Path or URL to your API documentation file. Only OpenApi 2.0 (Swagger) specification is currently supported."
        option :format, default: "yaml", values: %w[yaml json], desc: "Format of the definition"

        def call(**options)
          response = HTTP.headers(headers(options)).post(API_URL + "/previews", body: body(options).to_json)
          body = JSON.parse(response.body)

          if response.code == 201
            puts "Preview created : #{ROOT_URL + '/preview/' + body['id']} (expires at #{body['expires_at']})"
          elsif response.code == 422
            display_invalid_definition(body)
          else
            display_generic_error(body)
          end
        rescue HTTP::Error => error
          display_http_error(error)
        end

        private

        def headers(options)
          default_headers
        end

        def default_headers
          {
            "Content-Type" => "application/json"
          }
        end

        def body(options)
          {
            preview: {
              definition: open(options.fetch(:file)).read,
              format: options.fetch(:format)
            }
          }
        end

        def display_invalid_definition(body)
          puts "Definition is not valid:"
          body["errors"]["raw_definition"].each do |error|
            puts "> #{error}"
          end
          abort
        end

        def display_generic_error(body)
          abort body["message"]
        end

        def display_http_error(error)
          abort "#{error.class}: #{error.message}"
        end
      end
    end
  end
end
