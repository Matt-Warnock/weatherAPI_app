# frozen_string_literal: true

require 'pathname'
require 'yaml'

class CityNameConverter
  def initialize(file_path)
    @file_path = Pathname.new(file_path)
  end

  def name_to_id(name)
    city_codes[name]
  end

  def city_names
    city_codes.keys
  end

  private

  attr_reader :file_path

  def city_codes
    @city_codes ||= YAML.load_file(file_path)
  rescue Errno::ENOENT
    raise 'Invalid or missing .yml file'
  end
end
