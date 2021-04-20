# frozen_string_literal: true

require 'failure_response'
require 'rest-client'
require 'success_response'

class OpenWeatherClient
  def initialize(name_converter)
    @api_key = ENV['API_KEY']
    @api_url = ENV['API_URL']
    @name_converter = name_converter
  end

  def check_weather(city_name)
    city_id = name_converter.name_to_id(city_name)
    uri = URI.parse("#{api_url}/weather?id=#{city_id}&units=metric&appid=#{api_key}")

    rescue_errors { RestClient.get(uri.to_s) }
  end

  private

  attr_reader :api_key, :api_url, :name_converter

  def rescue_errors
    SuccessResponse.new(yield)
  rescue RestClient::ExceptionWithResponse => e
    FailureResponse.new(e)
  end
end
