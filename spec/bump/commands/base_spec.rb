require "spec_helper"

describe Bump::CLI::Commands::Base do
  class Bump::CLI::Commands::BaseErrors < Bump::CLI::Commands::Base
    def call
      with_errors_rescued do
        yield
      end
    end
  end

  class Bump::CLI::Commands::BasePost < Bump::CLI::Commands::Base
    def call(url:, body:, token: nil)
      post(url: url, body: body, token: token)
    end
  end

  it 'calls the given url with correct headers and body' do
    command = Bump::CLI::Commands::BasePost.new(command_name: 'Fake')
    stub_request(:post, "http://somewhere/")

    command.call(url: 'http://somewhere', body: 'hello world', token: '4815162342')

    expect(a_request(:post, 'http://somewhere').with(
      body: 'hello world',
      headers: {
        'User-Agent' => Bump::CLI::Commands::Base::USER_AGENT,
        'Authorization' => "Basic #{Base64.strict_encode64('4815162342:')}"
      }
    )).to have_been_made.once
  end

  it 'handles IO errors' do
    command = Bump::CLI::Commands::BaseErrors.new(command_name: 'Fake')

    expect do
      begin
        command.call do
          raise Errno::ENOENT.new('Oops')
        end
      rescue SystemExit; end
    end.to output(/Oops/).to_stderr
  end

  it 'handles socket errors' do
    command = Bump::CLI::Commands::BaseErrors.new(command_name: 'Fake')

    expect do
      begin
        command.call do
          raise SocketError.new('Oops')
        end
      rescue SystemExit; end
    end.to output(/Oops/).to_stderr
  end

  it 'handles http errors' do
    command = Bump::CLI::Commands::BaseErrors.new(command_name: 'Fake')

    expect do
      begin
        command.call do
          raise HTTP::Error.new('Oops')
        end
      rescue SystemExit; end
    end.to output(/Oops/).to_stderr
  end
end
