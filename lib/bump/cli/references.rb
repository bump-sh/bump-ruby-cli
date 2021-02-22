require "open-uri"
require "pathname"

module Bump
  class CLI
    class References < Hash
      def initialize(root_path: "")
        @root_path = root_path
      end

      def load(definition)
        traverse_and_load_external_references(definition) if definition.is_a?(Enumerable)
      end

      private

      attr_reader :root_path

      def traverse_and_load_external_references(current)
        current.each do |key, value|
          if key == "$ref"
            load_external_reference(value) if external?(value)
          elsif value.is_a?(Hash)
            traverse_and_load_external_references(value)
          elsif value.is_a?(Array)
            value.each do |array_value|
              if array_value.is_a?(Hash)
                traverse_and_load_external_references(array_value)
              end
            end
          end
        end
      end

      def load_external_reference(reference)
        if self[reference].nil?
          base_reference = cleanup_reference(reference)
          location = prepare_location(base_reference)
          self[base_reference] = URI.open(location).read.force_encoding(Encoding::UTF_8)
        end
      end

      def cleanup_reference(reference)
        reference.sub(/#.*/, "")
      end

      def prepare_location(reference)
        if url?(reference) || absolute_path?(reference)
          reference
        else
          root_path + reference
        end
      end

      def external?(reference)
        !reference.start_with?("#")
      end

      def url?(path)
        path.start_with?("http")
      end

      def absolute_path?(path)
        path.start_with?("/")
      end
    end
  end
end
