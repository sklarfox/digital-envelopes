require "bcrypt"
require "date"
require "sinatra"
require "tilt/erubis"
require "yaml"
require_relative "database_persistance"
require_relative "adjustment_log"

configure do
  enable :sessions
  set :session_secret,
      '80a613c2f7942425a9f66eabu1391821a51ad103801a4be1df9ca6d26c3fa698'
  set :erb, escape_html: true
end

configure(:development) do
  require "sinatra/reloader"
  also_reload "database_persistance.rb"
end

helpers do
  def sum(transactions)
    transactions.inject(0) { |memo, transaction| memo + transaction.amount }
  end

  def format_currency(amount)
    return unless amount
    "$#{format('%.2f', amount)}"
  end
end

def error_for_category_name(name)
  if !(1..30).cover? name.size
    "Category name must be between 1 and 30 characters."
  elsif @storage.all_categories.any? { |category| category[:name] == name }
    "The category name must be unique."
  end
end

def error_for_allocation_amount(amount)
  if amount.to_f.negative?
    'The allocation amount must be greater than 0.'
  elsif amount.chars.all? { |char| char.match?(/\d/) } ||
        amount.match?(/[0-9]+[.][0-9]{0,2}\z/)
    nil
  else
    "Invalid currency format. Please try again."
  end
end

def error_for_account_name(name)
  if !(1..30).cover? name.size
    "Account name must be between 1 and 30 characters."
  elsif @storage.all_accounts.any? { |account| account[:name] == name }
    "The account name must be unique."
  end
end

def error_for_amount(amount)
  if amount.to_f.negative?
    'The amount must be greater than 0.'
  elsif amount.to_f >= 100000000.00
    'The amount must be less than 99,999,999.99'
  elsif amount.chars.all? { |char| char.match?(/\d/) } ||
        amount.match?(/[0-9]+[.][0-9]{0,2}\z/)
    nil
  else
    "Invalid currency format. Please try again."
  end
end

def error_for_memo(memo)
  return unless memo.size > 30
  'The memo must be 30 characters or fewer.'
end

def load_user_credentials
  credentials_path = File.expand_path("../users.yml", __FILE__)
  YAML.load_file(credentials_path)
end

def valid_credentials?(username, password)
  credentials = load_user_credentials

  if credentials.key?(username)
    bcrypt_password = BCrypt::Password.new(credentials[username])
    bcrypt_password == password
  else
    false
  end
end

def redirect_unless_valid(*elements)
  elements.each do |element|
    if !element
      session[:error] = "The requested page doesn't exist."
      redirect '/budget'
    end
  end
end

def validate_page_input(input)
  if !input
    1
  elsif !input.chars.all? { |char| char.match(/\d/)}
    nil
  elsif input.to_i < 1
    nil
  else
    input.to_i
  end
end

def validate_id(id)
  if id.to_i.to_s != id
    nil
  else
    id.to_i
  end
end

before do
  @storage = DatabasePersistance.new
  @logger = AdjustmentLog.new

  unless session[:username] || env['REQUEST_PATH'] == '/login'
    session[:original_path] = env['REQUEST_PATH']
    session[:error] = 'Please log in to access that resource.'
    redirect '/login'
  end
end

get '/login' do
  erb :login, layout: :layout
end

post '/login' do
  username = params[:username]

  if valid_credentials?(username, params[:password])
    session[:username] = username
    session[:success] = 'Welcome! You have been logged in.'
    redirect session.delete(:original_path) || '/budget'
  else
    session[:error] = 'Invalid Credentials. Please try again.'
    status 422
    erb :login, layout: :layout
  end
end

post '/logout' do
  session.delete(:username)
  session[:success] = 'You have been successfully logged out.'
  redirect '/login'
end

get '/' do
  redirect "/budget"
end

get '/budget' do
  @page = validate_page_input(params[:page])
  @max_page = @storage.max_budget_page_number

  if !@page
    session[:error] = "Sorry, the page number you requested doesn't exist."
    redirect '/budget'
  elsif @page > @max_page
    session[:error] = "Sorry, the page number you requested doesn't exist."
    redirect '/budget'
  end

  @categories = @storage.load_categories(@page)
  @accounts = @storage.all_accounts

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

post '/category/:id/new_allocation' do
  amount = params[:new_assigned_amount]
  id = validate_id(params[:id])
  @category = @storage.load_category(id)
  @logger.log_adjustment(amount, @category)
  
  error = error_for_allocation_amount(amount)
  if error
    @categories = @storage.all_categories
    @accounts = @storage.all_accounts
    session[:error] = error
    erb :main, layout: :layout
  else
    session[:success] = "The assigned amount has been updated."
    @storage.set_category_assigned_amount(amount, id)
    redirect "/budget"
  end
end

get '/category/1' do
  redirect '/budget'
end

get '/category/:id' do
  id = validate_id(params[:id])
  @page = validate_page_input(params[:page])
  @category = @storage.load_category(id)
  @max_page = @storage.max_category_page_number(id)

  if !@category
    session[:error] = "Sorry, the category you requested doesn't exist."
    redirect '/budget'
  elsif !@page
    session[:error] = "Sorry, the page number you requested doesn't exist."
    redirect "/category/#{id}"
  elsif @page > @max_page
    session[:error] = "Sorry, the page number you requested doesn't exist."
    redirect "/category/#{id}"
  end

  @transactions = @storage.load_transactions_for_category(id, @page)
  erb :category, layout: :layout
end

get '/category/:id/edit' do
  id = validate_id(params[:id])
  @category = @storage.load_category(id)

  if !@category
    session[:error] = "Sorry, the category you requested doesn't exist."
    redirect '/budget'
  end

  erb :edit_category, layout: :layout
end

post '/category/:id/edit' do
  id = validate_id(params[:id])
  new_category_name = params[:new_category_name]
  @category = @storage.load_category(id)

  unless @category[:name] == new_category_name
    error = error_for_category_name(new_category_name)
  end

  if error
    session[:error] = error
    erb :edit_category, layout: :layout
  else
    @storage.change_category_name(id, new_category_name)
    session[:success] = 'The category name has been updated.'
    redirect "/category/#{@category[:id]}"
  end
end

get '/account/new' do
  erb :new_account, layout: :layout
end

post '/account/new' do
  account_name = params[:account_name]

  error = error_for_account_name(account_name)

  if error
    session[:error] = error
    erb :new_account, layout: :layout
  else
    session[:success] = "The account has been created."
    @storage.add_new_account(account_name)
    redirect "/budget"
  end
end

get '/account/:id' do
  id = validate_id(params[:id])
  @page = validate_page_input(params[:page])
  @account = @storage.load_account(id)
  @max_page = @storage.max_account_page_number(id)

  if !@account
    session[:error] = "Sorry, the account you requested doesn't exist."
    redirect '/budget'
  elsif !@page
    session[:error] = "Sorry, the page number you requested doesn't exist."
    redirect "/account/#{id}"
  elsif @page > @max_page
    session[:error] = "Sorry, the page number you requested doesn't exist."
    redirect "/account/#{id}"
  end
  @transactions = @storage.load_transactions_for_account(id, @page)
  erb :account, layout: :layout
end

get '/account/:id/edit' do
  id = validate_id(params[:id])
  @account = @storage.load_account(id)
  redirect_unless_valid(@account)
  erb :edit_account, layout: :layout
end

post '/account/:id/edit' do
  id = validate_id(params[:id])
  new_account_name = params[:new_account_name]
  @account = @storage.load_account(id)

  unless @account[:name] == new_account_name
    error = error_for_account_name(new_account_name)
  end

  if error
    session[:error] = error
    erb :edit_account, layout: :layout
  else
    @storage.change_account_name(id, new_account_name)
    session[:success] = 'The account name has been updated.'
    redirect "/account/#{@account[:id]}"
  end
end

get '/transaction/new' do
  @accounts = @storage.all_accounts
  @categories = @storage.all_categories
  erb :new_transaction, layout: :layout
end

post '/transaction/new' do
  amount = params[:amount].strip
  memo = params[:memo]
  date = params[:date]
  category_id = params[:category_id]
  account_id = params[:account_id]

  error = if error_for_amount(amount) && error_for_memo(memo)
            "#{error_for_amount(amount)} #{error_for_memo(memo)}"
          else
            error_for_amount(amount) || error_for_memo(memo)
          end

  if error
    @accounts = @storage.all_accounts
    @categories = @storage.all_categories
    session[:error] = error
    erb :new_transaction, layout: :layout
  else
    @storage.add_new_transaction(amount, memo, date, category_id, account_id)
    session[:success] = 'The transaction has been added.'
    redirect '/budget'
  end
end

get '/transaction/:id/edit' do
  id = validate_id(params[:id])
  @transaction = @storage.load_transaction(id)
  @categories = @storage.all_categories
  @accounts = @storage.all_accounts

  redirect_unless_valid(@transaction)
  erb :edit_transaction, layout: :layout
end

post '/transaction/:id/edit' do
  id = validate_id(params[:id])
  amount = params[:amount].strip
  memo = params[:memo]
  date = params[:date]
  category_id = params[:category_id]
  account_id = params[:account_id]

  error = if error_for_amount(amount) && error_for_memo(memo)
            "#{error_for_amount(amount)} #{error_for_memo(memo)}"
          else
            error_for_amount(amount) || error_for_memo(memo)
          end

  if error
    @transaction = @storage.load_transaction(id)
    @accounts = @storage.all_accounts
    @categories = @storage.all_categories
    session[:error] = error
    erb :edit_transaction, layout: :layout
  else
    @storage.change_transaction_details(amount, memo, date, category_id,
                                        account_id, id)
    session[:success] = 'The transaction has been updated.'
    redirect '/budget'
  end
end

post '/account/:id/delete' do
  id = params['id'].to_i
  @storage.delete_account(id)
  redirect '/budget'
end

post '/category/:id/delete' do
  id = params['id'].to_i
  @storage.delete_category(id)
  redirect '/budget'
end

post '/transaction/:id/delete' do
  id = params['id'].to_i
  @storage.delete_transaction(id)
  redirect '/budget'
end
