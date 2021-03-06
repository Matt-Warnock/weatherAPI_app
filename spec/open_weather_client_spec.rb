# frozen_string_literal: true

require 'city_name_converter'
require 'open_weather_client'

RSpec.describe OpenWeatherClient do
  let(:city_name) { 'London' }
  let(:client) { described_class.new(CityNameConverter.new('fixtures/test_city_list.yaml')) }
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
      stub_with_querys { |stub| stub.to_return(status: 200, body: weather_info) }

      result = client.check_weather(city_name)

      expect(result.body).to eq(weather_information)
    end

    context 'if timesout' do
      it 'does not raise an error' do
        stub_with_querys(&:to_timeout)

        expect { client.check_weather(city_name) }.not_to raise_error
      end

      it 'returns an custom response' do
        stub_with_querys(&:to_timeout)

        result = client.check_weather(city_name)

        expect(result).to be_an_instance_of(FailureResponse)
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

      it 'returns an custom response' do
        stub_with_querys { |stub| stub.to_return(status: 408) }

        result = client.check_weather(city_name)

        expect(result).to be_an_instance_of(FailureResponse)
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

  def weather_information # rubocop:disable Metrics/MethodLength
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
