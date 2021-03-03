require "spec_helper"

describe Bump::CLI::Commands::Deploy do
  it "calls the server and exit successfully if success" do
    stub_bump_api_validate("versions/post_success.http")
    allow(Bump::CLI::Resource).to receive(:read).and_return("body")

    expect {
      new_command.call(
        doc: "aaaa0000-bb11-cc22-dd33-eeeeee444444",
        "doc-name": "Hello world",
        hub: "aaaa0000-bb11-cc22-dd33-eeeeee444444",
        token: "token",
        file: "path/to/file",
        specification: "openapi/v2/json",
        validation: "strict",
        "auto-create": true
      )
    }.to output(/The new version is currently being processed/).to_stdout

    expect(WebMock).to have_requested(:post, "https://bump.sh/api/v1/versions").with(
      body: {
        documentation_id: "aaaa0000-bb11-cc22-dd33-eeeeee444444",
        documentation_name: "Hello world",
        hub_id: "aaaa0000-bb11-cc22-dd33-eeeeee444444",
        definition: "body",
        references: [],
        specification: "openapi/v2/json",
        validation: "strict",
        auto_create_documentation: true
      }
    )
  end

  it "handles external references by default" do
    stub_bump_api_validate("versions/post_success.http")
    allow(Bump::CLI::Resource).to receive(:read).with("path/to/file").and_return("$ref: https://example.url/openapi.yml")
    allow(Bump::CLI::Resource).to receive(:read).with("https://example.url/openapi.yml").and_return("hello: world")
    stub_request(:get, "https://example.url/openapi.yml").to_return(body: "hello: world")

    expect {
      new_command.call(
        doc: "aaaa0000-bb11-cc22-dd33-eeeeee444444",
        token: "token",
        file: "path/to/file"
      )
    }.to output(/The new version is currently being processed/).to_stdout

    expect(WebMock).to have_requested(:post, "https://bump.sh/api/v1/versions").with(
      body: {
        documentation_id: "aaaa0000-bb11-cc22-dd33-eeeeee444444",
        definition: "$ref: https://example.url/openapi.yml",
        references: [{location: "https://example.url/openapi.yml", content: "hello: world"}],
      }
    )
  end

  it "allows disabling external references import" do
    stub_bump_api_validate("versions/post_success.http")
    allow(Bump::CLI::Resource).to receive(:read).and_return("$ref: https://example.url/openapi.yml")
    stub_request(:get, "https://example.url/openapi.yml").to_return(body: "hello: world")

    expect {
      new_command.call(
        doc: "aaaa0000-bb11-cc22-dd33-eeeeee444444",
        token: "token",
        file: "path/to/file",
        "no-external-references": true
      )
    }.to output(/The new version is currently being processed/).to_stdout

    expect(WebMock).to have_requested(:post, "https://bump.sh/api/v1/versions").with(
      body: {
        documentation_id: "aaaa0000-bb11-cc22-dd33-eeeeee444444",
        definition: "$ref: https://example.url/openapi.yml",
        references: []
      }
    )
  end

  it "deploys with a slugs instead of ids" do
    stub_bump_api_validate("versions/post_success.http")
    allow(Bump::CLI::Resource).to receive(:read).and_return("body")

    expect {
      new_command.call(
        doc: "documentation-slug",
        hub: "hub-slug",
        file: "path/to/file"
      )
    }.to output(/The new version is currently being processed/).to_stdout

    expect(WebMock).to have_requested(:post, "https://bump.sh/api/v1/versions").with(
      body: hash_including(
        documentation_slug: "documentation-slug",
        hub_slug: "hub-slug"
      )
    )
  end

  it "supports deprecated id option and displays a warning" do
    stub_bump_api_validate("versions/post_success.http")
    allow(Bump::CLI::Resource).to receive(:read).and_return("body")

    expect {
      new_command.call(
        doc: "here-is-my-doc",
        file: "path/to/file",
        "import-external-references": true
      )
    }.to output(/\[DEPRECATION WARNING\]/).to_stdout
  end

  it "displays the definition errors in case of unprocessable entity" do
    stub_bump_api_validate("versions/post_unprocessable_entity.http")
    allow(Bump::CLI::Resource).to receive(:read).and_return("body")

    expect {
      begin
        new_command.call(doc: "1", token: "token", file: "path/to/file", specification: "openapi/v2/yaml", validation: "basic")
      rescue SystemExit; end
    }.to output(/Invalid request/).to_stderr
  end

  it "displays a generic error message in case of unknown error" do
    stub_bump_api_validate("versions/post_unknown_error.http")
    allow(Bump::CLI::Resource).to receive(:read).and_return("body")

    expect {
      begin
        new_command.call(doc: "1", token: "token", file: "path/to/file", specification: "openapi/v2/yaml", validation: "basic")
      rescue SystemExit; end
    }.to output(/Unknown error/).to_stderr
  end

  private

  def stub_bump_api_validate(path)
    stub_request(:post, %r{/versions}).to_return(read_http_fixture(path))
  end

  def new_command
    Bump::CLI::Commands::Deploy.new
  end
end
