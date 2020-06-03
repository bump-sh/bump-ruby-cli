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
