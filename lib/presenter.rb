# frozen_string_literal: true

class Presenter
  DEGREE_ENTITY = '&deg;'
  PERCENT_ENTITY = '&percnt;'
  TEMPERATURES_KEYS = %i[temp feels_like temp_min temp_max].freeze
  ICON_TO_CLASSNAME = {
    '01' => 'clear-sky',
    '02' => 'few-clouds',
    '03' => 'scattered-clouds',
    '04' => 'broken-clouds',
    '09' => 'shower-rain',
    '10' => 'rain',
    '11' => 'thunderstorm',
    '13' => 'snow',
    '50' => 'mist'
  }.freeze

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
    weather_data[:icon] = ICON_TO_CLASSNAME[data[:icon].chop]
    weather_data[:date] = utc_to_datatime
  end

  def display_date
    unix_to_utc.strftime('%a %e %b')
  end

  private

  attr_reader :name_converter, :user_choice

  def unix_to_utc
    Time.at(weather_data[:unix_date]).utc
  end

  def utc_to_datatime
    unix_to_utc.to_datetime.to_s
  end

  def format_temperatures
    weather_data.slice(*TEMPERATURES_KEYS).each_pair do |key, value|
      weather_data[key] = "#{value.round}#{DEGREE_ENTITY}C"
    end
  end
end
