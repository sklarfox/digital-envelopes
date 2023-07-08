require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"
require_relative 'budget_classes'
require_relative "database_persistance"

require 'pry'
require 'pry-byebug'

configure do
  enable :sessions
  set :session_secret, '80a613c2f7942425a9f66eabu1391821a51ad103801a4be1df9ca6d26c3fa698'
  set :erb, :escape_html => true
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "database_persistance.rb"
  also_reload "budget_classes.rb"
end

helpers do
  def to_be_assigned
    @storage.sum_all_inflows - @storage.sum_all_assigned_amounts
  end

  def sum(transactions)
    transactions.inject(0) { |memo, transaction| memo + transaction.amount }
  end
end

def error_for_category_name(name)
  if !(1..30).cover? name.size
    "Category name must be between 1 and 30 characters."
  elsif @storage.all_categories.any? { |category| category.name == name }
    "The category name must be unique."
  end
end

before do
  @storage = DatabasePersistance.new
end

get '/' do
  redirect "/budget"
end

get '/budget' do
  @categories = @storage.all_categories
  erb :main, layout: :layout
end

get '/category/new' do
  erb :new_category, layout: :layout
end

post '/category/new' do
  category_name = params[:category_name].strip

  error = error_for_category_name(category_name)
  if error
    session[:error] = error
    erb :new_category, layout: :layout
  else
    @storage.add_new_category(category_name)
    session[:success] = "The category has been created."
    redirect '/budget'
  end
end

get '/category/:id' do
  id = params[:id].to_i
  @category = @storage.load_category(id)
  @transactions = @storage.load_transactions_for_category(id)
  erb :category, layout: :layout
end
