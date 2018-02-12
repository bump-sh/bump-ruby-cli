module Bump
  class CLI
    class Authentication
      attr_reader :id, :token

      def initialize(authentication_string)
        @id, @token = authentication_string.split(':')
      end

      def id
        @id ||= ENV['BUMP_ID']
      end

      def token
        @token ||= ENV['BUMP_TOKEN']
      end

      def as_headers
        {
          "Authorization" => "Basic #{Base64.strict_encode64(token + ':')}"
        }
      end
    end
  end
end
