require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"
require_relative 'budget_classes'
require_relative "database_persistance"

require 'pry'
require 'pry-byebug'

configure do
  enable :sessions
  set :session_secret,
      '80a613c2f7942425a9f66eabu1391821a51ad103801a4be1df9ca6d26c3fa698'
  set :erb, escape_html: true
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

def error_for_allocation_amount(amount)
  return "The allocation amount must be greater than 0." unless amount >= 0
end

def error_for_account_name(name)
  if !(1..30).cover? name.size
    "Account name must be between 1 and 30 characters."
  elsif @storage.all_accounts.any? { |account| account.name == name }
    "The account name must be unique."
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
  @accounts = @storage.all_accounts
  erb :main, layout: :layout
end

get '/category/new' do
  erb :new_category, layout: :layout
end

post '/category/new_name' do
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

post '/category/:id/new_allocation' do
  amount = params[:new_assigned_amount].to_f
  id = params[:id].to_i
  @category = @storage.load_category(id)
  error = error_for_allocation_amount(amount)
  if error
    session[:error] = error
    erb :category, layout: :layout
  else
    session[:success] = "The assigned amount has been updated."
    @storage.set_category_assigned_amount(amount, id)
    redirect "/budget"
  end
end

get '/category/:id' do
  id = params[:id].to_i
  @category = @storage.load_category(id)
  @transactions = @storage.load_transactions_for_category(id)
  erb :category, layout: :layout
end

get '/account/new' do
  erb :new_account, layout: :layout
end

post '/account/new' do
  account_name = params[:account_name]

  error = error_for_account_name(account_name)

  if error
    session[:error] = error
    erb :category, layout: :layout
  else
    session[:success] = "The account has been created."
    @storage.add_new_account(account_name)
    redirect "/budget"
  end
end