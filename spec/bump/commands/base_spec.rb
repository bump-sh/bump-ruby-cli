require "spec_helper"

describe Bump::CLI::Commands::Base do
  it "calls the given url with correct headers and body" do
    command = Bump::CLI::Commands::BasePost.new
    stub_request(:post, "http://somewhere/")

    command.call(url: "http://somewhere", body: "hello world", token: "4815162342")

    expect(a_request(:post, "http://somewhere").with(
      body: "hello world",
      headers: {
        "User-Agent" => Bump::CLI::Commands::Base::USER_AGENT,
        "Authorization" => "Basic #{Base64.strict_encode64("4815162342:")}"
      }
    )).to have_been_made.once
  end

  it "handles IO errors" do
    command = Bump::CLI::Commands::BaseErrors.new

    expect {
      begin
        command.call do
          raise Errno::ENOENT.new("Oops")
        end
      rescue SystemExit; end
    }.to output(/Oops/).to_stderr
  end

  it "handles socket errors" do
    command = Bump::CLI::Commands::BaseErrors.new

    expect {
      begin
        command.call do
          raise SocketError.new("Oops")
        end
      rescue SystemExit; end
    }.to output(/Oops/).to_stderr
  end

  it "handles http errors" do
    command = Bump::CLI::Commands::BaseErrors.new

    expect {
      begin
        command.call do
          raise HTTP::Error.new("Oops")
        end
      rescue SystemExit; end
    }.to output(/Oops/).to_stderr
  end

  it "handles validation error" do
    command = Bump::CLI::Commands::BasePost.new
    stub_request(:post, "http://somewhere/").to_return(
      status: 422,
      body: {"errors" => {"raw_definition" => ["This is an error"]}}.to_json
    )

    expect {
      begin
        command.call(url: "http://somewhere", body: "hello")
      rescue SystemExit; end
    }.to output(/This is an error/).to_stderr
  end

  it "handles validation errors even when backend returns shit" do
    command = Bump::CLI::Commands::BasePost.new
    stub_request(:post, "http://somewhere/").to_return(
      status: 422,
      body: {"message" => "Invalid", "errors" => {"attribute" => "message"}}.to_json
    )

    expect {
      begin
        command.call(url: "http://somewhere", body: "hello")
      rescue SystemExit; end
    }.to output(/Invalid request:/).to_stderr
  end

  it "handles unexpected runtime errors" do
    command = Bump::CLI::Commands::BaseErrors.new

    expect {
      begin
        command.call { raise "Oops something bad happend" }
      rescue SystemExit; end
    }.to output(/You can help us fix this by creating an issue on https:\/\/github.com\/bump-sh\/bump-cli\/issues/).to_stderr
  end
end

class Bump::CLI::Commands::BaseErrors < Bump::CLI::Commands::Base
  def call
    with_errors_rescued do
      yield
    end
  end
end

class Bump::CLI::Commands::BasePost < Bump::CLI::Commands::Base
  def call(url:, body:, token: nil)
    response = post(url: url, body: body, token: token)

    if response.status > 400
      display_error(response)
    end
  end
end
