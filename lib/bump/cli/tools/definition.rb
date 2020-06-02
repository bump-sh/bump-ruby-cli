module Bump
  class CLI
    module Tools
      class Definition
        def initialize(path)
          @path = path
        end

        def prepare
          open(path).read
        end

        private

        attr_reader :path
      end
    end
  end
end
