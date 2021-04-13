# frozen_string_literal: true

require 'json'
require 'rest-client'

class OpenWeatherClient
  def initialize
    @api_key = ENV['API_KEY']
    @api_url = ENV['API_URL']
  end

  def check_weather(city_id)
    uri = URI.parse("#{@api_url}/weather?id=#{city_id}&units=metric&appid=#{@api_key}")
    response = RestClient.get(uri.to_s)

    raise RestClient::ExceptionWithResponse unless response.code == 200

    parse_json(response.body)
  rescue RestClient::ExceptionWithResponse, JSON::ParserError => e
    e
  end

  private

  def parse_json(response)
    JSON.parse(response, { symbolize_names: true })
  end
end
