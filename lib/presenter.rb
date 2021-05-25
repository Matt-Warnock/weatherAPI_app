# frozen_string_literal: true

class Presenter
  DEGREE_ENTITY = '&deg;'
  PERCENT_ENTITY = '&percnt;'
  TEMPERATURES_KEYS = %i[temp feels_like temp_min temp_max].freeze

  attr_reader :error, :weather_data

  def initialize(name_converter, user_choice = nil)
    @name_converter = name_converter
    @user_choice = user_choice
    @error = false
  end

  def city_names
    name_converter.city_names
  end

  def valid_city_name
    @error = 'Invalid city chosen' unless city_names.include?(user_choice)
    user_choice
  end

  def add_error(error_message)
    @error = error_message
  end

  def format_weather(data)
    return if data.empty?

    @weather_data = data
    format_temperatures
    weather_data[:humidity] = data[:humidity].to_s + PERCENT_ENTITY
    weather_data[:date] = format_date(data[:unix_date])
  end

  private

  attr_reader :name_converter, :user_choice

  def format_temperatures
    weather_data.slice(*TEMPERATURES_KEYS).each_pair do |key, value|
      weather_data[key] = "#{value.round}#{DEGREE_ENTITY}C"
    end
  end

  def format_date(unix_date)
    Time.at(unix_date).localtime.strftime('Today %a %e %b')
  end
end
