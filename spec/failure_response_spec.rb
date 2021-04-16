# frozen_string_literal: true

require 'rest-client'
require 'failure_response'

RSpec.describe FailureResponse do
  describe '#ok?' do
    it 'returns false' do
      custom_response = failure_response(nil)

      expect(custom_response.ok?).to be(false)
    end
  end

  describe '#body' do
    it 'returns key error message if 401 code is received' do
      custom_response = failure_response(401)

      expect(custom_response.body).to include('API key')
    end

    it 'returns an invalid city message if 404 code is received' do
      custom_response = failure_response(404)

      expect(custom_response.body).to include('invalid city')
    end

    it 'returns exception message on any other response codes' do
      custom_response = failure_response(408)

      expect(custom_response.body).to include('HTTP status code 408')
    end
  end

  def failure_response(status_code)
    response = instance_double('HTTP Response', code: status_code.to_s)
    described_class.new(RestClient::RequestFailed.new(response))
  end
end
