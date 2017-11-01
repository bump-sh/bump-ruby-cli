require "test_helper"

class Bump::CLITest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Bump::CLI::VERSION
  end
end
