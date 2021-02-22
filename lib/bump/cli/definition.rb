require "open-uri"
require "bump/cli/parser"
require "bump/cli/references"

module Bump
  class CLI
    class Definition
      attr_reader :content, :external_references

      def initialize(path, import_external_references: false)
        @path = path
        @import_external_references = import_external_references
        @external_references = References.new(root_path: find_base_path(path))
      end

      def prepare!
        @content = read_file

        if import_external_references
          external_references.load(parser.load(content))
        end
      end

      private

      attr_reader :path, :import_external_references

      def find_base_path(path)
        Pathname.new(path.to_s).dirname.to_s + Pathname::SEPARATOR_LIST
      end

      def read_file
        URI.open(path).read.force_encoding(Encoding::UTF_8)
      end

      def parser
        @parser ||= Parser.new
      end
    end
  end
end
