# frozen_string_literal: true

require 'rest-client'
require 'failure_response'

RSpec.describe FailureResponse do
  describe '#body' do
    it 'returns an empty hash' do
      custom_response = failure_response(404)

      expect(custom_response.body).to eq({})
    end

    it 'logs key error message if 401 code is received' do
      custom_response = failure_response(401)

      custom_response.body

      expect(custom_response.error_message).to include('API key')
    end

    it 'logs an invalid city message if 404 code is received' do
      custom_response = failure_response(404)

      custom_response.body

      expect(custom_response.error_message).to include('invalid city')
    end

    it 'logs exception message on any other response codes' do
      custom_response = failure_response(408)

      custom_response.body

      expect(custom_response.error_message).to include('HTTP status code 408')
    end
  end

  def failure_response(status_code)
    response = instance_double('HTTP Response', code: status_code.to_s)
    described_class.new(RestClient::RequestFailed.new(response))
  end
end
