require "test_helper"

describe Bump::CLI do
  around do |&block|
    modified_path = File.expand_path("../../..", __FILE__) + '/exe:' + ENV['PATH']
    ClimateControl.modify PATH: modified_path do
      super(&block)
    end
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
