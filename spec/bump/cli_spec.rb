require "spec_helper"

describe Bump::CLI do
  around(:each) do |example|
    modified_path = File.expand_path("../../..", __FILE__) + "/exe:" + ENV["PATH"]
    ClimateControl.modify PATH: modified_path do
      example.run
    end
  end

  describe "validate command" do
    it "outputs the right thing" do
      expect do
        print `bump validate`
      end.to output("Validating...\n").to_stdout
    end
  end

  describe "deploy command" do
    it "outputs the right thing" do
      expect do
        print `bump deploy`
      end.to output("Deploying...\n").to_stdout
    end
  end
end
