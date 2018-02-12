require "spec_helper"

describe Bump::CLI::Commands::Deploy do
  it 'calls the server and exit successfully if success' do
    stub_bump_api_validate('versions/post_success.http')

    expect do
      new_command.call(id: '1', token:'token', file: 'path/to/file', format: 'yaml')
    end.to output(/New version has been successfuly deployed/).to_stdout

    expect(WebMock).to have_requested(:post,'https://bump.sh/api/v1/docs/1/versions').with(
      body: {
        definition: 'body',
        format: 'yaml'
      }
    )
  end

  it 'displays the definition errors in case of unprocessable entity' do
    stub_bump_api_validate('versions/post_unprocessable_entity.http')

    expect do
      begin
        new_command.call(id: '1', token: 'token', file: 'path/to/file', format: 'yaml')
      rescue SystemExit; end
    end.to output(/Definition is not valid/).to_stdout
  end

  it 'displays a generic error message in case of unknown error' do
    stub_bump_api_validate('versions/post_unknown_error.http')

    expect do
      begin
        new_command.call(id: '1', token: 'token', file: 'path/to/file', format: 'yaml')
      rescue SystemExit; end
    end.to output(/Unknown error/).to_stderr
  end

  private

  def stub_bump_api_validate(path)
    stub_request(:post, %r{/versions}).to_return(read_http_fixture(path))
  end

  def new_command
    command = Bump::CLI::Commands::Deploy.new(command_name: 'validate')
    allow(command).to receive(:open).and_return(double(read: 'body'))
    command
  end
end
