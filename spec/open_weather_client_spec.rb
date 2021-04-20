# frozen_string_literal: true

require 'city_name_converter'
require 'open_weather_client'

RSpec.describe OpenWeatherClient do
  let(:city_name) { 'London' }
  let(:client) { described_class.new(CityNameConverter.new('fixtures/london_city_id.yaml')) }
  let(:weather_info) { File.open('fixtures/london_weather.json').read }

  describe '#check_weather' do
    it 'sends a get request to open weather api' do
      stub = stub_request(:get, %r{#{ENV['API_URL']}/weather})
             .to_return(status: 200, body: weather_info)

      client.check_weather(city_name)

      expect(stub).to have_been_requested
    end

    it 'converts the city name to id number and sends on the request' do
      stub = stub_request(:get, /2643743/)
             .to_return(status: 200, body: weather_info)

      client.check_weather(city_name)

      expect(stub).to have_been_requested
    end

    it 'sends the app key on the request' do
      stub = stub_request(:get, /#{ENV['API_KEY']}/)
             .to_return(status: 200, body: weather_info)

      client.check_weather(city_name)

      expect(stub).to have_been_requested
    end

    it 'sets the units to be metric on the request' do
      stub = stub_request(:get, /units=metric/)
             .to_return(status: 200, body: weather_info)

      client.check_weather(city_name)

      expect(stub).to have_been_requested
    end

    it 'returns weather infomation if successful' do
      weather_information = JSON.parse(weather_info, { symbolize_names: true })
      stub_with_querys { |stub| stub.to_return(status: 200, body: weather_info) }

      result = client.check_weather(city_name)

      expect(result.body).to eq(weather_information)
    end

    context 'if timesout' do
      it 'does not raise an error' do
        stub_with_querys(&:to_timeout)

        expect { client.check_weather(city_name) }.not_to raise_error
      end

      it 'returns a exception message' do
        stub_with_querys(&:to_timeout)

        result = client.check_weather(city_name)

        expect(result.body).to eq('Timed out connecting to server')
      end
    end

    context 'if response fails' do
      it 'does not raise an error' do
        stub_with_querys do |stub|
          stub.to_return(status: 408)
              .to_raise(RestClient::ExceptionWithResponse)
        end

        expect { client.check_weather(city_name) }.not_to raise_error
      end

      it 'returns a exception message' do
        stub_with_querys { |stub| stub.to_return(status: 408) }

        result = client.check_weather(city_name)

        expect(result.body).to eq('408 Request Timeout')
      end
    end
  end

  def stub_with_querys
    url = "#{ENV['API_URL']}/weather"
    stub = stub_request(:get, url).with(
      query: {
        'id' => '2643743',
        'units' => 'metric',
        'appid' => ENV['API_KEY']
      }
    )
    yield stub if block_given?
  end
end
