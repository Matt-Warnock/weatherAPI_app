# frozen_string_literal: true

require 'json'

class SuccessResponse
  attr_reader :error_message

  def initialize(response)
    @response = response
    @error_message = nil
  end

  def ok?
    true
  end

  def body
    if response.body.empty?
      @error_message = "I couldn't manage to get any weather info."
      return {}
    end

    @body ||= JSON.parse(response.body, { symbolize_names: true })
  rescue JSON::ParserError => e
    @error_message = "I got an unexpected result from Open Weather #{e}"
    {}
  end

  private

  attr_reader :response
end
