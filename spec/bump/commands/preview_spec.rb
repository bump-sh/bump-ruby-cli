require "spec_helper"

describe Bump::CLI::Commands::Preview do
  it 'calls the server and display the link on success' do
    stub_bump_api_create_preview('previews/post_success.http')

    expect do
      new_command.call(file: 'path/to/file', specification: 'openapi/v3/yaml', validation: 'strict')
    end.to output(/Preview created/).to_stdout

    expect(WebMock).to have_requested(:post,'https://bump.sh/api/v1/previews').with(
      headers: {
        'Content-Type': 'application/json'
      },
      body: {
        definition: 'body',
        specification: 'openapi/v3/yaml',
        validation: 'strict'
      }
    )
  end

  it 'displays the definition errors in case of unprocessable entity' do
    stub_bump_api_create_preview('previews/post_unprocessable_entity.http')

    expect do
      begin
        new_command.call(file: 'path/to/file', specification: 'openapi/v2/yaml', validation: 'basic')
      rescue SystemExit; end
    end.to output(/Invalid request/).to_stderr

    expect(WebMock).to have_requested(:post,'https://bump.sh/api/v1/previews')
  end

  it 'displays the error message in case of system error' do
    stub_bump_api_create_preview('previews/post_system_error.http')

    expect do
      begin
        new_command.call(file: 'path/to/file', specification: 'openapi/v2/yaml', validation: 'basic')
      rescue SystemExit; end
    end.to output(/Oops. Something bad happened./).to_stderr

    expect(WebMock).to have_requested(:post,'https://bump.sh/api/v1/previews')
  end

  private

  def stub_bump_api_create_preview(path)
    stub_request(:post, %r{/previews}).to_return(read_http_fixture(path))
  end

  def new_command
    command = Bump::CLI::Commands::Preview.new
    allow(command).to receive(:open).and_return(double(read: 'body'))
    command
  end
end
