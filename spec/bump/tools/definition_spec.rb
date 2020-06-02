require 'spec_helper'

describe Bump::CLI::Tools::Definition do
  describe '#prepare' do
    it 'opens the file and reads its content' do
      definition = Bump::CLI::Tools::Definition.new('path/to/file')
      file = spy(read: 'content')
      allow(definition).to receive(:open).and_return(file)

      expect(definition.prepare).to eq('content')
      expect(definition).to have_received('open').once.with('path/to/file')
      expect(file).to have_received('read').once
    end
  end
end
