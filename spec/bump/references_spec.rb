require 'spec_helper'

describe Bump::CLI::References do
  describe '#import!' do
    it 'it imports file system references' do
      references = Bump::CLI::References.new({
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
      references = Bump::CLI::References.new({
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
      references = Bump::CLI::References.new({
        'hello' => {
          '$ref' => '#/some/internal/path'
        }
      })
      references.import!

      expect(references.definition.dig('hello', '$ref')).to eq('#/some/internal/path')
    end

    it 'supports relative paths' do
      references = Bump::CLI::References.new({
        'hello' => {
          '$ref' => 'some/internal/path.yml'
        }
      }, base_path: '/somewhere/base.yml')
      allow(references).to receive(:open).and_return(spy(read: 'content'))

      references.import!

      expect(references).to have_received(:open).with('/somewhere/some/internal/path.yml')
    end

    it 'supports paths with subpaths' do
      references = Bump::CLI::References.new({
        'hello' => {
          '$ref' => 'some/internal/path.yml#subpath/subsub'
        }
      }, base_path: '/somewhere/base.yml')
      allow(references).to receive(:open).and_return(spy(read: 'content'))

      references.import!

      expect(references.definition.dig('hello', '$ref')).to eq('#/components/x-imported/1/subpath/subsub')
      expect(references.definition.dig('components', 'x-imported', '1')).to eq('content')
      expect(references).to have_received(:open).with('/somewhere/some/internal/path.yml')
    end

    it 'supports absolute paths' do
      references = Bump::CLI::References.new({
        'hello' => {
          '$ref' => '/some/absolute/path.yml'
        }
      }, base_path: '/somewhere/base.yml')
      allow(references).to receive(:open).and_return(spy(read: 'content'))

      references.import!

      expect(references).to have_received(:open).with('/some/absolute/path.yml')
    end

    it 'supports URI' do
      references = Bump::CLI::References.new({
        'hello' => {
          '$ref' => 'http://example.com/file.xml'
        }
      }, base_path: '/somewhere/base.yml')
      allow(references).to receive(:open).and_return(spy(read: 'content'))

      references.import!

      expect(references).to have_received(:open).with('http://example.com/file.xml')
    end

    it 'supports URI with subpaths' do
      references = Bump::CLI::References.new({
        'hello' => {
          '$ref' => 'http://example.com/file.xml#subpath/subsub'
        }
      }, base_path: '/somewhere/base.yml')
      allow(references).to receive(:open).and_return(spy(read: 'content'))

      references.import!

      expect(references.definition.dig('hello', '$ref')).to eq('#/components/x-imported/1/subpath/subsub')
      expect(references.definition.dig('components', 'x-imported', '1')).to eq('content')
      expect(references).to have_received(:open).with('http://example.com/file.xml')
    end

    it 'imports arrays with references' do
      references = Bump::CLI::References.new({
        'hello' => [
          { '$ref' => 'https://some.url/path' }
        ]
      })
      allow(references).to receive(:open).and_return(spy(read: 'content'))

      references.import!

      expect(references.definition['hello'][0]['$ref']).to eq('#/components/x-imported/1')
      expect(references.definition.dig('components', 'x-imported', '1')).to eq('content')
    end
  end
end
