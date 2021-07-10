# frozen_string_literal: true

require_relative '../sinatra_controler'

RSpec.describe 'sinatra_controler' do
  let(:database) { SQLDatabase.new(':memory:') }
  let(:name_converter) { CityNameConverter.new('fixtures/test_city_list.yaml') }

  def app
    SinatraControler.set :database, database
    SinatraControler.set :name_converter, name_converter
  end

  describe '/' do
    before { get '/' }

    it 'is succsessful' do
      expect(last_response).to be_ok
    end

    it 'displays list of citys to select' do
      total_citys = YAML.load_file('fixtures/test_city_list.yaml').keys.count

      expect(last_response.body.scan('name="city"').count).to eq(total_citys)
    end
  end

  describe '/weather' do
    let(:body) { File.open('fixtures/london_weather.json').read }

    it 'is succsessful' do
      weather_api_stub
      expect(last_response).to be_ok
    end

    context 'when no error has occured' do
      let(:any_html) { "(.|\n)*" }

      before { weather_api_stub }

      it 'displays temperatures' do
        expect(last_response.body).to match(
          /(14&deg;C)#{any_html}(12&deg;C)#{any_html}(13&deg;C)#{any_html}(Feels like 12&deg;C)/
        )
      end

      it 'displays weather description' do
        expect(last_response.body).to match('<p>overcast clouds</p>')
      end

      it 'displays city with date' do
        expect(last_response.body).to match(/#{any_html}(London)#{any_html}(Fri  9 Apr)/)
      end

      it 'displays weather humidity' do
        expect(last_response.body).to match('Humidity 47&percnt;')
      end

      it 'does not display error message' do
        expect(last_response.body).not_to include('Oopps! Something went wrong:')
      end
    end

    context 'when an error has occured' do
      before { weather_api_stub(404) }

      it 'displays error message' do
        expect(last_response.body).to include('Something went wrong: <br>I seemed to have lost the weather API!')
      end

      it 'does not display weather information' do
        expect(last_response.body).not_to include('Feels like 12&deg;C')
      end
    end

    def weather_api_stub(code = 200)
      url = "#{ENV['API_URL']}/weather"
      query = {
        'id' => '2643743',
        'units' => 'metric',
        'appid' => ENV['API_KEY']
      }
      stub_request(:get, url).with(query: query).to_return(status: code, body: body)
      post '/weather', cities: 'London'
    end
  end
end
