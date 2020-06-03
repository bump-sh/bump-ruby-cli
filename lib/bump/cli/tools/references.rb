require 'open-uri'

module Bump
  class CLI
    module Tools
      class References
        attr_reader :definition

        def initialize(definition)
          @definition = definition
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

        attr_reader :processed, :external_references

        def traverse_and_replace_external_references(current, parent = nil)
          current.each do |key, value|
            if key == '$ref'
              current[key] = replace_external_reference(value)
            elsif value.is_a?(Hash)
              traverse_and_replace_external_references(value, key)
            end
          end
        end

        def replace_external_reference(reference)
          if external?(reference)
            if external_references[reference].nil?
              @external_references[reference] = external_references.count + 1
            end

            "#/components/x-imported/#{external_references[reference]}"
          else
            reference
          end
        end

        def external?(reference)
          !reference.start_with?('#')
        end

        def import_references
          if external_references.count > 0
            @definition['components'] = {} if @definition['components'].nil?
            @definition['components']['x-imported'] = {} if @definition['components']['x-imported'].nil?

            external_references.each do |key, value|
              @definition['components']['x-imported'][value.to_s] = open(key).read
            end
          end
        end
      end
    end
  end
end
