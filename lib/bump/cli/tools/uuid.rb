module Bump
  class CLI
    module Tools
      class UUID
        REGEXP = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

        def self.valid?(string)
          string.to_s.match?(REGEXP)
        end
      end
    end
  end
end
