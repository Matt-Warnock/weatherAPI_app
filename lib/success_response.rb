# frozen_string_literal: true

require 'json'

class SuccessResponse
  attr_reader :error_message

  def initialize(response)
    @response = response
    @error_message = nil
  end

  def body
    if response.body.empty?
      @error_message = "I couldn't manage to get any weather info."
      return {}
    end

    @body ||= format_data(parse_body)
  rescue JSON::ParserError => e
    @error_message = "I got an unexpected result from Open Weather #{e}"
    {}
  end

  private

  def format_data(data)
    select_data = { name: data[:name], unix_date: data[:dt] }
    select_data[:description] = data.dig(:weather, 0, :description)
    select_data.merge((data[:main] || {}).except(:pressure))
  end

  def parse_body
    JSON.parse(response.body, { symbolize_names: true })
  end

  attr_reader :response
end
