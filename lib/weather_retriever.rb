# frozen_string_literal: true

class WeatherRetriever
  def initialize(client, database, presenter)
    @client = client
    @database = database
    @presenter = presenter
  end

  def run
    city_name = presenter.valid_city_name
    presenter.format_weather(weather_data(city_name))
  end

  private

  attr_reader :presenter, :database, :client

  def weather_data(city_name)
    stored_weather = database.retrieve_weather(city_name)

    if stored_weather.empty? || out_of_date?(stored_weather)
      augment_database_with(city_name)
      stored_weather = database.retrieve_weather(city_name)
    end
    stored_weather
  end

  def augment_database_with(city_name)
    response = client.check_weather(city_name)
    return presenter.add_error(response.error_message) unless response.ok?

    successful_entry = database.augment(response.body)
    presenter.add_error(database.error_message) unless successful_entry
  end

  def out_of_date?(stored_weather)
    date_stored = Time.at(stored_weather[:unix_date]).utc
    a_day_in_seconds = 24 * 3600
    date_stored + a_day_in_seconds < Time.now.utc
  end
end
