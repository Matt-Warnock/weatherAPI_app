# frozen_string_literal: true

class FailureResponse
  attr_reader :error_message

  def initialize(error)
    @error = error
    @error_message = nil
  end

  def body
    @error_message = check_error
    {}
  end

  private

  def check_error
    case @error.http_code
    when 401
      'Your API key is invalid!'
    when 404
      'I seemed to have lost the weather API!
 It might be because an invalid city was entered.'
    else
      @error.message
    end
  end
end
