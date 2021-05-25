# frozen_string_literal: true

require 'city_name_converter'

RSpec.describe CityNameConverter do
  let(:converter) { described_class.new('fixtures/test_city_list.yaml') }

  describe '#name_to_id' do
    it 'converts a city name to its designated city id code' do
      expect(converter.name_to_id('London')).to eq(2_643_743)
    end

    it 'raises a custom error message if pathname does not contain a vaild yaml file' do
      converter = described_class.new('irelevent.yaml')

      expect { converter.name_to_id('London') }.to raise_error('Invalid or missing .yml file')
    end
  end

  describe '#city_names' do
    it 'returns all city names in YAML file' do
      expect(converter.city_names).to eq(%w[London Brighton])
    end
  end
end
