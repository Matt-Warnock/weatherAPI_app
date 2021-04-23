# frozen_string_literal: true

require 'sqlite3'

class SQLDatabase
  attr_reader :error_message

  def initialize(file_path)
    @db = SQLite3::Database.new(file_path)
    @error_message = nil
    create_table
    setup_name_index
  end

  def augment(data)
    db.execute('INSERT OR REPLACE INTO weather(
      name, unix_date, description, temp, feels_like, temp_min, temp_max, humidity
      ) VALUES(?, ?, ?, ?, ?, ?, ?, ?)', order_row(data))

    true
  rescue SQLite3::ConstraintException => e
    @error_message = "Bad weather data! #{e}"
    false
  end

  def retrieve_weather(city)
    db.query('SELECT * FROM weather WHERE name = ?', city) do |row|
      result = row.next_hash || {}
      result.transform_keys(&:to_sym)
    end
  end

  private

  attr_reader :db

  def order_row(data)
    row = data.values_at(:name, :dt)
    row << data[:weather].first[:description]
    row + data[:main].values_at(
      :temp, :feels_like, :temp_min, :temp_max, :humidity
    )
  end

  def create_table
    db.execute 'CREATE TABLE IF NOT EXISTS weather(
    id INTEGER PRIMARY KEY,
    name VARCHAR(10) NOT NULL,
    unix_date INTEGER NOT NULL,
    description VARCHAR(20),
    temp REAL NOT NULL,
    feels_like REAL,
    temp_min REAL,
    temp_max REAL,
    humidity INTEGER);'
  end

  def setup_name_index
    db.execute 'CREATE UNIQUE INDEX IF NOT EXISTS idx_name ON weather(name);'
  end
end
