# frozen_string_literal: true

require 'open_weather_client'

RSpec.describe OpenWeatherClient do
  let(:city_id) { 2_643_743 }
  let(:client) { described_class.new }
  let(:weather_info) { File.open('fixtures/london_weather.json').read }

  describe '#check_weather' do
    it 'sends a get request to open weather api' do
      stub = stub_request(:get, %r{#{ENV['API_URL']}/weather})
             .to_return(status: 200, body: weather_info)

      client.check_weather(city_id)

      expect(stub).to have_been_requested
    end

    it 'sends the passed city id on the request' do
      stub = stub_request(:get, /#{city_id}/)
             .to_return(status: 200, body: weather_info)

      client.check_weather(city_id)

      expect(stub).to have_been_requested
    end

    it 'sends the app key on the request' do
      stub = stub_request(:get, /#{ENV['API_KEY']}/)
             .to_return(status: 200, body: weather_info)

      client.check_weather(city_id)

      expect(stub).to have_been_requested
    end

    it 'sets the units to be metric on the request' do
      stub = stub_request(:get, /units=metric/)
             .to_return(status: 200, body: weather_info)

      client.check_weather(city_id)

      expect(stub).to have_been_requested
    end

    it 'returns weather infomation if successful' do
      weather_information = JSON.parse(weather_info, { symbolize_names: true })
      stub_with_querys { |stub| stub.to_return(status: 200, body: weather_info) }

      result = client.check_weather(city_id)

      expect(result).to eq(weather_information)
    end

    context 'if timesout' do
      it 'does not raise an error' do
        stub_with_querys(&:to_timeout)

        expect { client.check_weather(city_id) }.not_to raise_error
      end

      it 'returns a restclient exception' do
        stub_with_querys(&:to_timeout)

        result = client.check_weather(city_id)

        expect(result.message).to eq('Timed out connecting to server')
      end
    end

    context 'if response fails' do
      it 'does not raise an error' do
        stub_with_querys do |stub|
          stub.to_return(status: 408)
              .to_raise(RestClient::ExceptionWithResponse)
        end

        expect { client.check_weather(city_id) }.not_to raise_error
      end

      it 'returns a restclient exception' do
        stub_with_querys { |stub| stub.to_return(status: 408) }

        result = client.check_weather(city_id)

        expect(result.message).to eq('408 Request Timeout')
      end
    end

    it 'raises an exception if anything other than a 200 response code' do
      stub_with_querys { |stub| stub.to_return(status: 204) }

      result = client.check_weather(city_id)

      expect(result.message).to eq('RestClient::ExceptionWithResponse')
    end

    context 'if response is invaild json' do
      it 'does not raise an error' do
        stub_with_querys { |stub| stub.to_return(status: 200, body: '<html></html>') }

        expect { client.check_weather(city_id) }.not_to raise_error
      end

      it 'returns an exception' do
        stub_with_querys { |stub| stub.to_return(status: 200, body: '<html></html>') }

        result = client.check_weather(city_id)

        expect(result.message).to eq("809: unexpected token at '<html></html>'")
      end
    end
  end

  def stub_with_querys
    url = 'https://api.openweathermap.org/data/2.5/weather'
    stub = stub_request(:get, url).with(
      query: {
        'id' => city_id.to_s,
        'units' => 'metric',
        'appid' => ENV['API_KEY']
      }
    )
    yield stub if block_given?
  end
end
