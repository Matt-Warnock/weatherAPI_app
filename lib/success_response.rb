# frozen_string_literal: true

require 'json'

class SuccessResponse
  attr_reader :error_message

  def initialize(response)
    @response = response
    @error_message = nil
  end

  def ok?
    body
    !error_message
  end

  def body
    return {} if response.body.empty?

    @body ||= format_data(parse_body)
  rescue JSON::ParserError => e
    @error_message = e.message
    {}
  end

  private

  def format_data(data)
    condition = data.dig(:weather, 0) || {}
    select_data = {
      name: data[:name], unix_date: data[:dt], description: condition[:description], icon: condition[:icon]
    }
    select_data.merge((data[:main] || {}).except(:pressure))
  end

  def parse_body
    JSON.parse(response.body, { symbolize_names: true })
  end

  attr_reader :response
end
