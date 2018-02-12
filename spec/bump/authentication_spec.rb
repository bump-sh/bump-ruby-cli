require "spec_helper"

describe Bump::CLI::Authentication do
  describe '#id' do
    it 'extracts id from the input authentication string' do
      service = Bump::CLI::Authentication.new('1:yolo')

      expect(service.id).to eq('1')
    end

    it 'extracts id from ENV' do
      ClimateControl.modify BUMP_ID: '2' do
        service = Bump::CLI::Authentication.new('')

        expect(service.id).to eq('2')
      end
    end
  end

  describe '#token' do
    it 'extracts token from the input authentication string' do
      service = Bump::CLI::Authentication.new('1:auth_token')

      expect(service.token).to eq('auth_token')
    end

    it 'extracts token from ENV' do
      ClimateControl.modify BUMP_TOKEN: 'auth_token' do
        service = Bump::CLI::Authentication.new('')

        expect(service.token).to eq('auth_token')
      end
    end
  end
end
