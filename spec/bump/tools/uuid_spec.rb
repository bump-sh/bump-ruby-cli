require "spec_helper"

describe Bump::CLI::Tools::UUID do
  describe '#valid?' do
    it 'returns true for real uuids' do
      expect(Bump::CLI::Tools::UUID.valid?('d3b559ab-d601-49d7-990a-d7f9a4a2ed89')).to be_truthy
    end

    it 'returns false for other strings' do
      expect(Bump::CLI::Tools::UUID.valid?('not-not-not')).to be_falsey
    end
  end
end
