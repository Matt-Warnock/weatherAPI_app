# frozen_string_literal: true

class FailureResponse
  def initialize(error)
    @error = error
  end

  def ok?
    false
  end

  def body
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
