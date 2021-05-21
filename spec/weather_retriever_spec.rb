# frozen_string_literal: true

require 'open_weather_client'
require 'city_name_converter'
require 'sql_database'
require 'weather_retriever'

RSpec.describe WeatherRetriever do
  let(:presenter) { double('presenter') }
  let(:sql) { SQLite3::Database.open('file::memory:?cache=shared') }
  let(:today) { Time.utc(2021, 4, 9, 13, 0, 1) }
  let(:weather_info) { File.open('fixtures/london_weather.json').read }

  before do
    allow(Time).to receive(:now).and_return today
    presenter_stub
  end

  after { sql.execute 'DROP TABLE weather' }

  describe '#run' do
    it 'collects the city name' do
      open_weather_stub
      set_up_retriever.run

      expect(presenter).to have_received(:city_name).once
    end

    context 'When successful' do
      before { open_weather_stub }

      context 'when database is up to data' do
        let(:earier_today) { Time.utc(today.year, today.month, today.day, today.hour - 3).to_i }

        before do
          create_table
          setup_name_index
          add_weather_row(earier_today)
        end

        it 'does not call the client' do
          set_up_retriever.run

          expect(open_weather_stub).not_to have_been_made
        end

        it 'does not augment the database' do
          set_up_retriever.run

          result = sql.query "SELECT * FROM weather WHERE name = 'London'" do |rows|
            rows.next_hash.transform_keys(&:to_sym)
          end

          expect(result[:unix_date]).to eq(earier_today)
        end

        it 'returns weather' do
          set_up_retriever.run

          expect(presenter).to have_received(:collect_weather).with(todays_weather(date: earier_today))
        end
      end

      context 'when database is empty' do
        it 'calls the client' do
          set_up_retriever.run

          expect(open_weather_stub).to have_been_made.once
        end

        it 'augments the database' do
          set_up_retriever.run

          result = sql.query "SELECT * FROM weather WHERE name = 'London'" do |rows|
            rows.next_hash.transform_keys(&:to_sym)
          end

          expect(result).to eq(todays_weather)
        end

        it 'returns updated weather' do
          set_up_retriever.run

          expect(presenter).to have_received(:collect_weather).with(todays_weather)
        end

        it 'has no client or database errors' do
          set_up_retriever.run

          expect(presenter).not_to have_received(:log_error)
        end
      end

      context 'when database has outdated data' do
        let(:two_days_ago) { Time.utc(today.year, today.month, today.day - 2).to_i }

        before do
          create_table
          setup_name_index
          add_weather_row(two_days_ago)
        end

        it 'calls the client' do
          set_up_retriever.run

          expect(open_weather_stub).to have_been_made.once
        end

        it 'augments the database' do
          set_up_retriever.run

          result = sql.query "SELECT * FROM weather WHERE name = 'London'" do |rows|
            rows.next_hash.transform_keys(&:to_sym)
          end

          expect(result).to eq(todays_weather(id: 2))
        end

        it 'returns updated weather' do
          set_up_retriever.run

          expect(presenter).to have_received(:collect_weather).with(todays_weather(id: 2))
        end

        it 'has no client or database errors' do
          set_up_retriever.run

          expect(presenter).not_to have_received(:log_error)
        end
      end
    end

    context 'when failure' do
      before { open_weather_stub(status: 404) }

      it 'returns no weather' do
        set_up_retriever.run

        expect(presenter).to have_received(:collect_weather).with({})
      end

      it 'does not augment database' do
        set_up_retriever.run

        result = sql.query("SELECT * FROM weather WHERE name = 'London'", &:none?)

        expect(result).to be true
      end

      it 'logs the error if client fails' do
        set_up_retriever.run

        expect(presenter).to have_received(:log_error).once.with(
          "I seemed to have lost the weather API!\n It might be because an invalid city was entered."
        )
      end

      it 'logs the error when response data is bad' do
        bad_data = { foo: 'bar' }
        open_weather_stub(status: 200, body: bad_data.to_json)

        set_up_retriever.run

        expect(presenter).to have_received(:log_error).once.with('NOT NULL constraint failed: weather.name')
      end
    end
  end

  def set_up_retriever
    described_class.new(
      OpenWeatherClient.new(CityNameConverter.new('fixtures/london_city_id.yaml')),
      SQLDatabase.new('file::memory:?cache=shared'),
      presenter
    )
  end

  def presenter_stub
    allow(presenter).to receive(:city_name) { 'London' }
    allow(presenter).to receive(:collect_weather).with(kind_of(Hash))
    allow(presenter).to receive(:log_error).with(kind_of(String))
  end

  def open_weather_stub(status: 200, body: weather_info)
    url = "#{ENV['API_URL']}/weather"
    query = {
      'id' => '2643743',
      'units' => 'metric',
      'appid' => ENV['API_KEY']
    }
    stub_request(:get, url).with(query: query).to_return(status: status, body: body)
  end

  def todays_weather(id: 1, date: today.to_i) # rubocop:disable Metrics/MethodLength
    {
      id: id,
      name: 'London',
      unix_date: date,
      description: 'overcast clouds',
      temp: 13.04,
      feels_like: 11.63,
      temp_min: 11.67,
      temp_max: 14.44,
      humidity: 47
    }
  end

  def create_table
    sql.execute 'CREATE TABLE weather(
    id INTEGER PRIMARY KEY, name, unix_date, description, temp, feels_like, temp_min, temp_max, humidity
    );'
  end

  def setup_name_index
    sql.execute 'CREATE UNIQUE INDEX idx_name ON weather(name);'
  end

  def add_weather_row(unix_date = today.to_i)
    order_row = ['London', unix_date, 'overcast clouds', 13.04, 11.63, 11.67, 14.44, 47]

    sql.execute('INSERT INTO weather(
    name, unix_date, description, temp, feels_like, temp_min, temp_max, humidity
    ) VALUES(?, ?, ?, ?, ?, ?, ?, ?)', order_row)
  end
end
