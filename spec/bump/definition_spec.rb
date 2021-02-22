require "spec_helper"

describe Bump::CLI::Definition do
  describe "#prepare" do
    it "opens the file and reads its content" do
      definition = Bump::CLI::Definition.new("path/to/file")
      allow(URI).to receive(:open).and_return(spy(read: "content"))

      definition.prepare!

      expect(definition.content).to eq("content")
      expect(URI).to have_received("open").once.with("path/to/file")
    end

    it "loads the definition and import references" do
      definition = Bump::CLI::Definition.new("path/to/file", import_external_references: true)
      allow(definition).to receive(:parse_file_and_import_external_references).and_return("content")

      definition.prepare!

      expect(definition.content).to eq("content")
      expect(definition).to have_received(:parse_file_and_import_external_references).once
    end

    it "loads YAML definition and serializes it correctly" do
      definition = Bump::CLI::Definition.new("path/to/file", import_external_references: true)
      allow(definition).to receive(:read_file).and_return("property: value")

      definition.prepare!

      expect(definition.content).to include("property: value")
    end

    it "loads JSON definition and serializes it correctly" do
      definition = Bump::CLI::Definition.new("path/to/file", import_external_references: true)
      allow(definition).to receive(:read_file).and_return('{"property": "value"}')

      definition.prepare!

      expect(definition.content).to include('{"property":"value"}')
    end
  end
end
