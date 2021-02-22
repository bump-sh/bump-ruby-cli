require "spec_helper"

describe Bump::CLI::References do
  describe "#load" do
    it "it imports file system references" do
      references = Bump::CLI::References.new(root_path: "/app/specification/")
      allow(URI).to receive(:open).and_return(spy(read: "content"))

      references.load({
        "hello" => {
          "$ref" => "some/filesystem/path"
        },
        "another" => {
          "$ref" => "./some/other/filesystem/path"
        },
        "absolute" => {
          "$ref" => "/some/absolute/filesystem/path"
        }
      })

      expect(references["some/filesystem/path"]).to eq("content")
      expect(URI).to have_received(:open).with("/app/specification/some/filesystem/path")
      expect(references["./some/other/filesystem/path"]).to eq("content")
      expect(URI).to have_received(:open).with("/app/specification/some/filesystem/path")
      expect(references["/some/absolute/filesystem/path"]).to eq("content")
      expect(URI).to have_received(:open).with("/some/absolute/filesystem/path")
    end

    it "imports URI references" do
      references = Bump::CLI::References.new
      stub_request(:get, "https://some.url/path").to_return(body: "content")

      references.load({
        "hello" => {
          "$ref" => "https://some.url/path#/relativePath/"
        }
      })

      expect(references["https://some.url/path"]).to eq("content")
    end

    it "ignores internal references" do
      references = Bump::CLI::References.new

      references.load({
        "hello" => {
          "$ref" => "#/some/internal/path"
        }
      })

      expect(references.size).to eq(0)
    end

    it "imports arrays with references" do
      references = Bump::CLI::References.new
      stub_request(:get, "https://some.url/path").to_return(body: "content")

      references.load({
        "hello" => [
          {"$ref" => "https://some.url/path"},
          "something_else"
        ]
      })

      expect(references["https://some.url/path"]).to eq("content")
    end
  end
end
