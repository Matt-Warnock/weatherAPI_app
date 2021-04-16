# frozen_string_literal: true

require 'yaml'

class CityNameConverter
  def initialize(file_path)
    @file_path = Pathname.new(file_path)
  end

  def name_to_id(name)
    load_file[name]
  end

  private

  attr_reader :file_path

  def load_file
    YAML.load_file(file_path)
  rescue Errno::ENOENT
    raise 'Invalid or missing .yml file'
  end
end
