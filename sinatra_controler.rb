# frozen_string_literal: true

require 'sinatra'

require_relative 'lib/city_name_converter'
require_relative 'lib/open_weather_client'
require_relative 'lib/presenter'
require_relative 'lib/sql_database'
require_relative 'lib/weather_retriever'

class SinatraControler < Sinatra::Base
  set :database, SQLDatabase.new('city_weather.db')
  set :name_converter, CityNameConverter.new('locales/city_list.yaml')

  get '/' do
    @page = Presenter.new(settings.name_converter)

    erb :index
  end

  post '/weather' do
    client = OpenWeatherClient.new(settings.name_converter)

    @page = Presenter.new(settings.name_converter, params['cities'])
    WeatherRetriever.new(client, settings.database, @page).run

    if @page.error
      erb :error
    else
      erb :result
    end
  end
end
