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

configure do
  enable :sessions
  Account.create_table
  Pool.create_table
  Match.create_table
  Pick.create_table
  
  begin
      admin = Account.new("admin", "Admin@123456", "admin")
      admin.save
  rescue
      #ignore
  end
end

get '/' do
    if session == nil || session[:login] == nil
            redirect '/login'
    end
    
    redirect '/scores'
end

get '/login' do
  erb :login
end

post '/login' do
  login = params[:login]
  password = params[:password]
  user = Account.find_by_login(login)
  
  if (user != nil && user.password == password)
    session[:login] = user
    user.role == 'admin' ? redirect('/open') : redirect('/scores')
  end
  
  @error = "Wrong username and/or password"
  erb :login
end

get '/register' do
  erb :register
end

post '/register' do
  login = params[:login]
  password = params[:password]
  password_c = params[:password_confirm]
  
  if password != password_c
    @error = 'The passwords don\'t match'
    puts @error
    erb :register
  elsif Account.find_by_login(login)
    @error = 'That login already exists'
    puts @error
    erb :register
  else  
    user = Account.new(login, password, 'user')
    user.save
    session[:login] = user
    user.role == 'admin' ? redirect('/open') : redirect('/scores')
  end 
end

get '/open' do
    login = session[:login]
    puts login
    if login == nil || login.role != 'admin'
      redirect '/'
    end
  
    erb :openPool
end

post '/open' do
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
  erb :closePool
end

post '/close' do
  
end

get '/pick' do
  erb :pick
end

post '/pick' do
  
end

get '/results' do
  
end

post '/results' do
  
end

get '/scores' do
  erb :scores
end

post '/scores' do
  
end
