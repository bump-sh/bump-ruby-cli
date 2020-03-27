require "spec_helper"

describe Bump::CLI::Commands::Deploy do
  it 'calls the server and exit successfully if success' do
    stub_bump_api_validate('versions/post_success.http')

    expect do
      new_command.call(
        documentation: 'aaaa0000-bb11-cc22-dd33-eeeeee444444',
        hub: 'aaaa0000-bb11-cc22-dd33-eeeeee444444',
        token:'token',
        file: 'path/to/file',
        specification: 'openapi/v2/json',
        validation: 'strict')
    end.to output(/New version has been successfully deployed/).to_stdout

    expect(WebMock).to have_requested(:post,'https://bump.sh/api/v1/versions').with(
      body: {
        documentation_id: 'aaaa0000-bb11-cc22-dd33-eeeeee444444',
        hub_id: 'aaaa0000-bb11-cc22-dd33-eeeeee444444',
        definition: 'body',
        specification: 'openapi/v2/json',
        validation: 'strict'
      }
    )
  end

  it 'deploys with a slugs instead of ids' do
    stub_bump_api_validate('versions/post_success.http')

    expect do
      new_command.call(
        documentation: 'documentation-slug',
        hub: 'hub-slug',
        file: 'path/to/file'
      )
    end.to output(/New version has been successfully deployed/).to_stdout

    expect(WebMock).to have_requested(:post,'https://bump.sh/api/v1/versions').with(
      body: hash_including(
        documentation_slug: 'documentation-slug',
        hub_slug: 'hub-slug'
      )
    )
  end

  it 'displays the definition errors in case of unprocessable entity' do
    stub_bump_api_validate('versions/post_unprocessable_entity.http')

    expect do
      begin
        new_command.call(id: '1', token: 'token', file: 'path/to/file', specification: 'openapi/v2/yaml', validation: 'basic')
      rescue SystemExit; end
    end.to output(/Invalid request/).to_stderr
  end

  it 'displays a generic error message in case of unknown error' do
    stub_bump_api_validate('versions/post_unknown_error.http')

    expect do
      begin
        new_command.call(id: '1', token: 'token', file: 'path/to/file', specification: 'openapi/v2/yaml', validation: 'basic')
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
