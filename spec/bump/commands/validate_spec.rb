require "spec_helper"

describe Bump::CLI::Commands::Validate do
  it 'calls the server and exit successfully if success' do
    stub_bump_api_validate('validations/post_success.http')

    expect do
      new_command.call(authentication: '1:token', file: 'path/to/file', format: 'yaml')
    end.to output(/Definition is valid/).to_stdout

    expect(WebMock).to have_requested(:post,'https://bump.sh/api/v1/docs/1/validations').with(
      body: {
        definition: 'body',
        format: 'yaml'
      }
    )
  end

  it 'displays the definition errors in case of unprocessable entity' do
    stub_bump_api_validate('validations/post_unprocessable_entity.http')

    expect do
      begin
        new_command.call(authentication: 'YO:LO', file: 'path/to/file', format: 'yaml')
      rescue SystemExit; end
    end.to output(/Definition is not valid/).to_stdout
  end

  it 'displays a generic error message in case of unknown error' do
    stub_bump_api_validate('validations/post_unknown_error.http')

    expect do
      begin
        new_command.call(authentication: 'YO:LO', file: 'path/to/file', format: 'yaml')
      rescue SystemExit; end
    end.to output(/Unknown error/).to_stderr
  end

  private

  def stub_bump_api_validate(path)
    stub_request(:post, %r{/validations}).to_return(read_http_fixture(path))
  end

  def new_command
    command = Bump::CLI::Commands::Validate.new(command_name: 'validate')
    allow(command).to receive(:open).and_return(double(read: 'body'))
    command
  end
end
