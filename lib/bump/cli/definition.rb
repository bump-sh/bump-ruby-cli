require 'open-uri'
require 'bump/cli/parser'
require 'bump/cli/references'

module Bump
  class CLI
    class Definition
      def initialize(path, import_external_references: false)
        @path = path
        @import_external_references = import_external_references
        @content = nil
      end

      def prepare
        if !import_external_references
          @content = read_file
        else
          @content = parse_file_and_import_external_references
        end
      end

      def write(to:)
        File.write(to, @content)
      end

      private

      attr_reader :path, :import_external_references

      def read_file
        open(path).read
      end

      def parse_file_and_import_external_references
        original_format, definition = parser.load(read_file)

        references = References.new(definition, base_path: path)
        references.import!

        parser.dump(references.definition, original_format)
      end

      def parser
        @parser ||= Parser.new
      end
    end
  end
end
