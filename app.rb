require "sinatra"
require "sinatra/reloader" if development?
require "pry-byebug"
require "better_errors"
require 'csv'

configure :development do
  use BetterErrors::Middleware
  BetterErrors.application_root = File.expand_path('..', __FILE__)
end

# get '/' do
#   erb :index
# end



get '/about' do
  erb :about
end

get '/new' do
  erb :new
end

post '/' do
  Cookbook.new('recipes.csv').add_recipe(Recipe.new(params[:recipe_name], params[:recipe_description]))
  @recipes = Cookbook.new('recipes.csv')
  erb :index
end

get '/' do
  @recipes = Cookbook.new('recipes.csv')
  erb :index
end

get '/delete/:number' do
  Cookbook.new('recipes.csv').remove_recipe(params[:number].to_i)
  @recipes = Cookbook.new('recipes.csv')
  erb :index
end

class Recipe
  attr_reader :name, :description, :time

  def initialize(name, description, time = "No details")
    @name = name
    @description = description
    @time = time
  end
end

require 'csv'

class Cookbook
  attr_reader :recipes

  def initialize(csv_file_path)
    @recipes = []
    @csv_file_path = csv_file_path
    CSV.foreach(@csv_file_path) do |recipe|
      @recipes << Recipe.new(recipe[0], recipe[1], recipe[2])
    end
    return @recipes
  end

  def all
    return @recipes
  end

  def add_recipe(recipe)
    @recipes << recipe
    CSV.open(@csv_file_path, 'wb') do |csv|
      @recipes.each { |recipe_instance| csv << [recipe_instance.name, recipe_instance.description, recipe_instance.time] }
    end
  end

  def remove_recipe(recipe_index)
    @recipes.delete_at(recipe_index)
    CSV.open(@csv_file_path, 'wb') do |csv|
      @recipes.each { |recipe_instance| csv << [recipe_instance.name, recipe_instance.description, recipe_instance.time] }
    end
  end
end

