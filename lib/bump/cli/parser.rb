require 'json'
require 'yaml'

module Bump
  class CLI
    class Parser
      def load(content)
        [:json, ::JSON.parse(content)]
      rescue ::JSON::ParserError => e
        begin
          [:yaml, ::YAML.safe_load(content, [Date, Time])]
        rescue ::Psych::SyntaxError
          [:text, content]
        end
      end

      def dump(definition, format)
        if format == :yaml
          ::YAML.dump(definition)
        else
          ::JSON.dump(definition)
        end
      end
    end
  end
end
