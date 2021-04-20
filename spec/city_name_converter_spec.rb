# frozen_string_literal: true

require 'city_name_converter'

RSpec.describe CityNameConverter do
  describe '#name_to_id' do
    it 'converts a city name to its designated city id code' do
      converter = described_class.new('fixtures/london_city_id.yaml')

      expect(converter.name_to_id('London')).to eq(2_643_743)
    end

    it 'raises a custom error message if pathname does not contain a vaild yaml file' do
      converter = described_class.new('irelevent.yaml')

      expect { converter.name_to_id('London') }.to raise_error('Invalid or missing .yml file')
    end
  end
end
