# Final Project: Soccer Pool
# Date: 30-Nov-2015
# Authors: A01164759 Mauricio Cunillé Blando
#          A01169513 Daniela Ortiz Rodríguez

require 'sinatra'
require 'sinatra/content_for'
require_relative 'models/Account'
require_relative 'models/Match'
require_relative 'models/Pick'
require_relative 'models/Pool'

### Helper methods ###
helpers do
  def protected!
    return if authorized?
    halt 401, "Not authorized\n"
  end

  # Whether the user is logged in.
  def logged_in?
    session != nil && session[:login] != nil
  end

  # Whethet the user is an admin.
  def authorized?
    logged_in? && session[:login].role == 'admin'
  end
end

## Configures the server ##
configure do
  enable :sessions
  
  # Creates the database
  Account.create_table
  Pool.create_table
  Match.create_table
  Pick.create_table
  
  # Create default admin credentials.
  begin
      admin = Account.new("admin", "Admin@123456", "admin")
      admin.save
  rescue
      # Ignore, the account was already created.
  end
end

# GET: /
# The application index.
get '/' do
  redirect '/login' if !logged_in?
  redirect '/scores'
end

# GET: /login
# The login page.
get '/login' do
  @viewTitle = "Login"
  erb :login
end

# POST: /login
#
# Parameter::
#
#   login:: The username.
#   password: The password.
post '/login' do
  login = params[:login]
  password = params[:password]
  
  user = Account.find_by_login(login)
  
  if user != nil && user.validate_credentials(password)
    session[:login] = user
    redirect '/'
  end
  
  @viewTitle = "Login"
  @error = "Wrong username and/or password."
  erb :login
end

# GET: /logout
# Logs out the user from the system.
get '/logout' do
  session[:login] = nil
  redirect '/'
end

# GET: /register
# The application sign up page.
get '/register' do
  @viewTitle = "Sign up"
  erb :register
end

# POST: /register
#
# Parameter::
#
#   login:: The username.
#   password:: The password.
#   password_confirm:: The password confirmation.
post '/register' do
  login = params[:login]
  password = params[:password]
  password_c = params[:password_confirm]
  
  @viewTitle = "Sign up"
  
  if password != password_c
    @error = 'The passwords don\'t match'
    erb :register
    return
  elsif Account.find_by_login(login)
    @error = 'That login already exists'
    erb :register
    return
  end
  
  user = Account.new(login, password, 'user')
  user.save
  
  redirect '/login'
end

# GET: /open
# The page where the admin can open new pools.
get '/open' do
  redirect '/login' if !logged_in?
  protected!
  
  if Pool.find_open != nil
    @unique_error = true
  end
  
  
  @viewTitle = "New pool"
  erb :openPool
end

post '/open' do
  redirect '/login' if !logged_in?
  protected!
 
  @viewTitle = "New pool"
  
  if Pool.find_open != nil
    @unique_error = true
    erb :openPool
    return
  end
 
  pool = Pool.new(Pool::OPEN)
  pool.save
    
  teams = {}
    
  params.each {|e|
    data = e[0].split('_')
    if teams[data[1]] == nil
      teams[data[1]] = Match.new(nil, nil, Match::NO_RESULTS, pool)
    end
        
    if data[0].end_with?('A')
      teams[data[1]].firstTeam = e[1]
    else
      teams[data[1]].secondTeam = e[1]
    end
  }
    
  teams.each {|e|
    e[1].save
  }
    
  redirect '/close'
end

get '/close' do
  redirect '/login' if !logged_in?
  protected!
  
  @viewTitle = "Close pool"
  erb :closePool
end

post '/close' do
  redirect '/login' if !logged_in?
  protected!
  
  @viewTitle = "Close pool"
end

get '/pick' do
  redirect '/login' if !logged_in?
  
  @viewTitle = "Make your pick"
  erb :pick
end

post '/pick' do
  redirect '/login' if !logged_in?
  @viewTitle = "Make your pick"
end

get '/results' do
  redirect '/login' if !logged_in?
  protected!
  
  @viewTitle = "Match results"
end

post '/results' do
  redirect '/login' if !logged_in?
  protected!
  
  @viewTitle = "Match results"
end

get '/scores' do
  redirect '/login' if !logged_in?
  @viewTitle = "Scores"
  erb :scores
end

post '/scores' do
  redirect '/login' if !logged_in?
  @viewTitle = "Scores"
end