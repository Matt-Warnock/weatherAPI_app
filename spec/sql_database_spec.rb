# frozen_string_literal: true

require 'sql_database'

RSpec.describe SQLDatabase do
  let!(:database) { described_class.new('file::memory:?cache=shared') }
  let(:sql) { SQLite3::Database.open('file::memory:?cache=shared') }

  after { sql.execute 'DROP TABLE weather' }

  it 'only creates a table with name index if has not been created already' do
    expect do
      create_table
      described_class.new('file::memory_1:?cache=shared&mode=memory')
    end.not_to raise_error
  end

  describe '#augment' do
    it 'adds weather information to the database' do
      database.augment(london_weather_data)

      result = sql.query "SELECT * FROM weather WHERE name = 'London'" do |rows|
        rows.next_hash.transform_keys(&:to_sym)
      end

      expect(result).to eq(london_sql_data)
    end

    it 'updates the database if the same weather information already exists' do
      database.augment(london_weather_data)
      database.augment(london_weather_data)

      result = sql.query "SELECT * FROM weather WHERE name = 'London'"

      expect(result.count).to eq(1)
    end

    it 'returns true if no expections are made' do
      result = database.augment(london_weather_data)

      expect(result).to be true
    end

    context 'if data is bad' do
      bad_data = { foo: 'bar' }

      it 'does not raise an error' do
        expect { database.augment(bad_data) }.not_to raise_error
      end

      it 'returns false' do
        result = database.augment(bad_data)

        expect(result).to be false
      end

      it 'logs a failure message' do
        database.augment(bad_data)

        expect(database.error_message).to include('Bad weather data! NOT NULL constraint failed')
      end
    end
  end

  describe '#retrieve_weather' do
    it 'searches name with column index' do
      add_weather_row

      result = sql.query(
        "EXPLAIN QUERY PLAN SELECT * FROM weather WHERE name = 'London'", &:next_hash
      )

      expect(result['detail']).to include('USING INDEX idx_name')
    end

    it 'returns weather information matching city name passed' do
      add_weather_row

      result = database.retrieve_weather('London')

      expect(result).to eq(london_sql_data)
    end

    it 'returns an empty hash if no matching city name is found' do
      add_weather_row

      result = database.retrieve_weather('Not in the database')

      expect(result).to eq({})
    end
  end

  def london_weather_data
    {
      name: 'London',
      unix_date: 1_617_973_201,
      description: 'overcast clouds',
      temp: 13.04,
      feels_like: 11.63,
      temp_min: 11.67,
      temp_max: 14.44,
      humidity: 47
    }
  end

  def london_sql_data
    london_weather_data.merge({ id: 1 })
  end

  def add_weather_row
    order_row = ['London', 1_617_973_201, 'overcast clouds', 13.04, 11.63, 11.67, 14.44, 47]

    sql.execute('INSERT INTO weather(
    name, unix_date, description, temp, feels_like, temp_min, temp_max, humidity
    ) VALUES(?, ?, ?, ?, ?, ?, ?, ?)', order_row)
  end

  def create_table
    sql = SQLite3::Database.open('file::memory_1:?cache=shared&mode=memory')
    sql.execute 'CREATE TABLE weather(name);'
    sql.execute 'CREATE INDEX idx_name ON weather(name);'
  end
end
