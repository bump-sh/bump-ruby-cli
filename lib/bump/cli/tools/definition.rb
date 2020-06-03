require 'bump/cli/tools/references'

module Bump
  class CLI
    module Tools
      class Definition
        def initialize(path, import_external_references: false)
          @path = path
          @import_external_references = import_external_references
        end

        def prepare
          if !import_external_references
            read_file
          else
            parse_file_and_import_external_references
          end
        end

        private

        attr_reader :path, :import_external_references

        def read_file
          open(path).read
        end

        def parse_file_and_import_external_references
          original_format, definition = load_file

          references = References.new(definition)
          references.import!

          serialize(references.definition, original_format)
        end

        def load_file
          parse_content(read_file)
        end

        def parse_content(content)
          [:json, JSON.parse(content)]
        rescue JSON::ParserError => e
          [:yaml, YAML.safe_load(content, [Date, Time])]
        rescue Psych::SyntaxError
          raise 'Invalid format: definition file should be valid YAML or JSON'
        end

        def serialize(definition, format)
          if format == :yaml
            YAML.dump(definition)
          else
            JSON.dump(definition)
          end
        end
      end
    end
  end
end
