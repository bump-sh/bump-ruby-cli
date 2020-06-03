require 'spec_helper'

describe Bump::CLI::Tools::References do
  describe '#import!' do
    it 'it imports file system references' do
      references = Bump::CLI::Tools::References.new({
        'hello' => {
          '$ref' => 'some/filesystem/path'
        },
        'another' => {
          '$ref' => 'some/other/filesystem/path'
        },
        'duplicate' => {
          '$ref' => 'some/filesystem/path'
        },
      })
      allow(references).to receive(:open).and_return(spy(read: 'content'))

      references.import!

      expect(references.definition.dig('hello', '$ref')).to eq('#/components/x-imported/1')
      expect(references.definition.dig('another', '$ref')).to eq('#/components/x-imported/2')
      expect(references.definition.dig('duplicate', '$ref')).to eq('#/components/x-imported/1')
      expect(references.definition.dig('components', 'x-imported', '1')).to eq('content')
      expect(references.definition.dig('components', 'x-imported', '2')).to eq('content')
    end

    it 'imports URI references' do
      references = Bump::CLI::Tools::References.new({
        'hello' => {
          '$ref' => 'https://some.url/path'
        }
      })
      allow(references).to receive(:open).and_return(spy(read: 'content'))

      references.import!

      expect(references.definition.dig('hello', '$ref')).to eq('#/components/x-imported/1')
      expect(references.definition.dig('components', 'x-imported', '1')).to eq('content')
    end

    it 'ignores internal references' do
      references = Bump::CLI::Tools::References.new({
        'hello' => {
          '$ref' => '#/some/internal/path'
        }
      })
      references.import!

      expect(references.definition.dig('hello', '$ref')).to eq('#/some/internal/path')
    end
  end
end
