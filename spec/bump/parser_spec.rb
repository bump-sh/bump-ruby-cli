require 'spec_helper'

describe Bump::CLI::Parser do
  describe '#load' do
    it 'loads YAML definition and serializes it correctly' do
      format, definition = Bump::CLI::Parser.new.load('property: value')

      expect(format).to eq(:yaml)
      expect(definition).to eq('property' => 'value')
    end

    it 'loads JSON definition and serializes it correctly' do
      format, definition = Bump::CLI::Parser.new.load('{"property": "value"}')

      expect(format).to eq(:json)
      expect(definition).to eq('property' => 'value')
    end

    it 'correctly fallbacks to simple text definition' do
      format, definition = Bump::CLI::Parser.new.load("Not valid YAML: something.\n 0: #nop!")

      expect(format).to eq(:text)
      expect(definition).to eq("Not valid YAML: something.\n 0: #nop!")
    end
  end

  describe '#dump' do
    it 'loads YAML definition and serializes it correctly' do
      result = Bump::CLI::Parser.new.dump({ 'property' => 'value' }, :yaml)

      expect(result).to include('property: value')
    end

    it 'loads JSON definition and serializes it correctly' do
      result = Bump::CLI::Parser.new.dump({ 'property' => 'value' }, :json)

      expect(result).to include('{"property":"value"}')
    end
  end
end
