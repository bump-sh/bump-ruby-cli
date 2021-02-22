require "json"
require "yaml"

module Bump
  class CLI
    class Resource
      def self.parse(content)
        ::JSON.parse(content)
      rescue ::JSON::ParserError => e
        begin
          ::YAML.safe_load(content, [Date, Time])
        rescue ::Psych::SyntaxError
          content
        end
      end
    end
  end
end
