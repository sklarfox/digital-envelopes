require "sinatra"
require "sinatra/content_for"
require "tilt/erubis"
require_relative "budget_classes"
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
  also_reload
end

helpers do

end

get '/' do
  'hello world'
end