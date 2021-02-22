require "spec_helper"

describe Bump::CLI::Resource do
  describe ".parse" do
    it "parses YAML definition and serializes it correctly" do
      definition = Bump::CLI::Resource.parse("property: value")

      expect(definition).to eq("property" => "value")
    end

    it "parses JSON definition and serializes it correctly" do
      definition = Bump::CLI::Resource.parse("{\"property\": \"value\"}")

      expect(definition).to eq("property" => "value")
    end

    it "correctly fallbacks to simple text definition" do
      definition = Bump::CLI::Resource.parse("Not valid YAML: something.\n 0: #nop!")

      expect(definition).to eq("Not valid YAML: something.\n 0: #nop!")
    end
  end
end
