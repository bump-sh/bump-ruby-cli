require 'open-uri'
require 'pathname'

module Bump
  class CLI
    class References
      attr_reader :definition

      def initialize(definition, base_path: '')
        @definition = definition
        @base_path = cleanup(base_path)
        @processed = false
        @external_references = {}
      end

      def import!
        if !processed
          @definition = traverse_and_replace_external_references(definition)
          import_references
          @processed = true
        end
      end

      private

      attr_reader :base_path, :processed, :external_references

      def traverse_and_replace_external_references(current)
        current.each do |key, value|
          if key == '$ref'
            current[key] = replace_external_reference(value)
          elsif value.is_a?(Hash)
            traverse_and_replace_external_references(value)
          elsif value.is_a?(Array)
            value.each do |array_value|
              traverse_and_replace_external_references(array_value)
            end
          end
        end
      end

      def replace_external_reference(reference)
        if external?(reference)
          if external_references[reference].nil?
            @external_references[reference] = "#{external_references.count + 1}"
          end

          subpath = reference[/#(.*)$/, 1]
          "#/components/x-imported/#{external_references[reference]}#{ '/' + subpath if !subpath.nil? }"
        else
          reference
        end
      end

      def import_references
        if external_references.count > 0
          @definition['components'] = {} if @definition['components'].nil?
          @definition['components']['x-imported'] = {} if @definition['components']['x-imported'].nil?

          external_references.each do |key, value|
            _, @definition['components']['x-imported'][value.to_s] = Parser.new.load(open(prepare_path(key)).read)
          end
        end
      end

      def prepare_path(key)
        key = key.sub(/#.*/, '')
        if url?(key) || absolute_path?(key)
          key
        else
          base_path + key
        end
      end

      def external?(reference)
        !reference.start_with?('#')
      end

      def url?(path)
        path.start_with?('http')
      end

      def absolute_path?(path)
        path.start_with?('/')
      end

      def cleanup(path)
        Pathname.new(path).dirname.to_s + Pathname::SEPARATOR_LIST
      end
    end
  end
end
