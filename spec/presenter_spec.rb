# frozen_string_literal: true

require 'presenter'
require 'city_name_converter'

RSpec.describe Presenter do
  let(:name_converter) { CityNameConverter.new('fixtures/test_city_list.yaml') }
  let(:presenter) { described_class.new(name_converter, 'London') }

  describe '#city_names' do
    it 'returns an array of citys names' do
      result = presenter.city_names

      expect(result).to eq(%w[London Brighton])
    end
  end

  describe '#valid_city_name' do
    it 'returns the user chosen name' do
      result = presenter.valid_city_name

      expect(result).to eq('London')
    end

    it 'flags error if user choice is invalid' do
      presenter = described_class.new(name_converter, 'invalid city')

      presenter.valid_city_name

      expect(presenter.error).to eq('Invalid city chosen')
    end

    it 'does not flags error if user choice is valid' do
      presenter.valid_city_name

      expect(presenter.error).to be false
    end
  end

  describe '#add_error' do
    it 'flags error with error message string' do
      error_message = '404: page not found'

      presenter.add_error(error_message)

      expect(presenter.error).to eq(error_message)
    end
  end

  describe '#format_weather' do
    it 'formats the weather data' do
      presenter.format_weather(unformated_data)

      expect(presenter.weather_data).to eq(formated_data)
    end

    it 'does not raise error if given empty data' do
      expect { presenter.format_weather({}) }.to_not raise_error
    end
  end

  def unformated_data
    {
      name: 'London',
      temp: 13.04,
      feels_like: 11.63,
      temp_min: 11.67,
      temp_max: 14.44,
      humidity: 47,
      unix_date: 1_617_973_201
    }
  end

  def formated_data
    {
      name: 'London',
      temp: '13&deg;C',
      feels_like: '12&deg;C',
      temp_min: '12&deg;C',
      temp_max: '14&deg;C',
      humidity: '47&percnt;',
      unix_date: 1_617_973_201,
      date: 'Today Fri  9 Apr'
    }
  end
end
