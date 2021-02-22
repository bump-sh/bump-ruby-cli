require "json"
require "yaml"

module Bump
  class CLI
    class Resource
      def self.read(location)
        if location.start_with?("http")
          ::HTTP.get(location).to_s
        else
          ::File.read(location).force_encoding(Encoding::UTF_8)
        end
      end

      def self.parse(content)
        ::JSON.parse(content)
      rescue ::JSON::ParserError
        begin
          ::YAML.safe_load(content, [Date, Time])
        rescue ::Psych::SyntaxError
          content
        end
      end
    end
  end
end
