require "spec_helper"

describe Bump::CLI::Resource do
  describe ".read" do
    it "handles URL location" do
      allow(HTTP).to receive(:get).and_return("hello: world")

      content = Bump::CLI::Resource.read("https://example.com/source.yml")

      expect(content).to eq("hello: world")
      expect(HTTP).to have_received(:get).with("https://example.com/source.yml")
    end

    it "handles file system location" do
      allow(File).to receive(:read).and_return("hello: world")

      content = Bump::CLI::Resource.read("./source.yml")

      expect(content).to eq("hello: world")
      expect(File).to have_received(:read).with("./source.yml")
    end
  end

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
