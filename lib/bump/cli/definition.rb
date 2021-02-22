require "bump/cli/references"
require "bump/cli/resource"

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
        @content = Resource.read(path)

        if import_external_references
          external_references.load(Resource.parse(content))
        end
      end

      private

      attr_reader :path, :import_external_references

      def find_base_path(path)
        Pathname.new(path.to_s).dirname.to_s + Pathname::SEPARATOR_LIST
      end
    end
  end
end
