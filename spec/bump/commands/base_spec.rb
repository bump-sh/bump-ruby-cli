require "spec_helper"

describe Bump::CLI::Commands::Base do
  class Bump::CLI::Commands::BaseFake < Bump::CLI::Commands::Base
    def call
      with_errors_rescued do
        yield
      end
    end
  end

  it 'handles IO errors' do
    command = Bump::CLI::Commands::BaseFake.new(command_name: 'Fake')

    expect do
      begin
        command.call do
          raise Errno::ENOENT.new('Oops')
        end
      rescue SystemExit; end
    end.to output(/Oops/).to_stderr
  end

  it 'handles socket errors' do
    command = Bump::CLI::Commands::BaseFake.new(command_name: 'Fake')

    expect do
      begin
        command.call do
          raise SocketError.new('Oops')
        end
      rescue SystemExit; end
    end.to output(/Oops/).to_stderr
  end

  it 'handles http errors' do
    command = Bump::CLI::Commands::BaseFake.new(command_name: 'Fake')

    expect do
      begin
        command.call do
          raise HTTP::Error.new('Oops')
        end
      rescue SystemExit; end
    end.to output(/Oops/).to_stderr
  end
end
