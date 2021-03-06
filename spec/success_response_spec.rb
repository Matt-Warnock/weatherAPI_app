# frozen_string_literal: true

require 'rest-client'
require 'success_response'

RSpec.describe SuccessResponse do
  let(:weather_body) { File.open('fixtures/london_weather.json').read }

  describe '#ok?' do
    it 'returns a truthy value if JSON parse is successful' do
      custom_response = described_class.new(successful_response)

      expect(custom_response.ok?).to be true
    end

    it 'returns a falsely value if JSON parse fails' do
      custom_response = described_class.new(successful_response('irelivent'))

      expect(custom_response.ok?).to be false
    end
  end

  describe '#body' do
    it 'returns an empty hash if response has an empty body' do
      custom_response = described_class.new(successful_response(''))

      expect(custom_response.body).to eq({})
    end

    it 'returns formated body information from response in ruby' do
      custom_response = described_class.new(successful_response)

      expect(custom_response.body).to eq(london_weather_output)
    end

    it 'does not raise an error if unexpected hash is received' do
      custom_response = described_class.new(successful_response({ bacon: 'eggs' }.to_json))

      expect { custom_response.body }.not_to raise_error
    end

    context 'if json parse fails' do
      it 'does not raise an error' do
        custom_response = described_class.new(successful_response('irelivent'))

        expect { custom_response.body }.not_to raise_error
      end

      it 'creates an exception message' do
        custom_response = described_class.new(successful_response('irelivent'))
        custom_response.body

        expect(custom_response.error_message).to include("809: unexpected token at 'irelivent'")
      end

      it 'returns an empty hash' do
        custom_response = described_class.new(successful_response('irelivent'))

        expect(custom_response.body).to eq({})
      end
    end
  end

  def successful_response(body = weather_body)
    stub_request(:get, 'http//test').to_return(body: body)
    RestClient.get('http//test')
  end

  def london_weather_output # rubocop:disable Metrics/MethodLength
    {
      name: 'London',
      unix_date: 1_617_973_201,
      description: 'overcast clouds',
      icon: '04d',
      temp: 13.04,
      feels_like: 11.63,
      temp_min: 11.67,
      temp_max: 14.44,
      humidity: 47
    }
  end
end
