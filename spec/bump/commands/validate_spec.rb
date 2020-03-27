require "spec_helper"

describe Bump::CLI::Commands::Validate do
  it 'calls the server and exit successfully if success' do
    stub_bump_api_validate('validations/post_success.http')

    expect do
      new_command.call(
        documentation: 'aaaa0000-bb11-cc22-dd33-eeeeee444444',
        token:'token',
        file: 'path/to/file',
        specification: 'api-blueprint/v1a9',
        validation: 'strict')
    end.to output(/Definition is valid/).to_stdout

    expect(WebMock).to have_requested(:post,'https://bump.sh/api/v1/validations').with(
      body: {
        documentation_id: 'aaaa0000-bb11-cc22-dd33-eeeeee444444',
        definition: 'body',
        specification: 'api-blueprint/v1a9',
        validation: 'strict'
      }
    )
  end

  it 'validates with a documentation slug' do
    stub_bump_api_validate('validations/post_success.http')

    expect do
      new_command.call(documentation: 'a-slug', file: 'path/to/file')
    end.to output(/Definition is valid/).to_stdout

    expect(WebMock).to have_requested(:post,'https://bump.sh/api/v1/validations').with(
      body: hash_including(
        documentation_slug: 'a-slug'
      )
    )
  end

  it 'displays the definition errors in case of unprocessable entity' do
    stub_bump_api_validate('validations/post_unprocessable_entity.http')

    expect do
      begin
        new_command.call(id: '1', token:'token', file: 'path/to/file', specification: 'openapi/v2/yaml', validation: 'basic')
      rescue SystemExit; end
    end.to output(/Invalid request/).to_stderr
  end

  it 'displays a generic error message in case of unknown error' do
    stub_bump_api_validate('validations/post_unknown_error.http')

    expect do
      begin
        new_command.call(id: '1', token:'token', file: 'path/to/file', specification: 'openapi/v2/yaml', validation: 'basic')
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
