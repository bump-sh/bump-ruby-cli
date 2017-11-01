require "test_helper"

describe Bump::CLI do
  before do
    @original_path = ENV['PATH']
    ENV['PATH'] = File.expand_path("../../..", __FILE__) + '/exe:' + ENV['PATH']
  end

  after do
    ENV['PATH'] = @original_path
  end

  it "has a version number" do
    refute_nil ::Bump::CLI::VERSION
  end

  describe "validate command" do
    it "outputs the right thing" do
      output = `bump validate`

      assert_equal output.chomp, "Validating..."
    end
  end

  describe "deploy command" do
    it "outputs the right thing" do
      output = `bump deploy`

      assert_equal output.chomp, "Deploying..."
    end
  end
end
