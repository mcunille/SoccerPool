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
  @viewTitle = "Log in"
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
  
  @viewTitle = "Log in"
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
    return erb :register
  elsif Account.find_by_login(login)
    @error = 'That login already exists'
    return erb :register
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
  
  if Pool.find_open != nil || Pool.find_closed != nil
    @unique_error = true
  end
  
  @viewTitle = "New pool"
  erb :openPool
end

post '/open' do
  redirect '/login' if !logged_in?
  protected!
 
  @viewTitle = "New pool"
  
  if Pool.find_open != nil || Pool.find_closed != nil
    @unique_error = true
    return erb :openPool
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
  @pool = Pool.find_open
  erb :closePool
end

post '/close' do
  redirect '/login' if !logged_in?
  protected!
  
  @viewTitle = "Close pool"
  rowid = params[:rowid]
  pool = Pool.find(rowid)
  
  if !pool
    @error = "Something weird happened. We couldn't find your open pool."
    return erb :closePool
  end
  
  pool.open = Pool::CLOSED
  pool.save
  
  redirect '/results'
end

get '/results' do
  redirect '/login' if !logged_in?
  protected!
  
  @viewTitle = "Match results"
  @pool = Pool.find_closed
  @results = {}
  
  if @pool
    @pool.matches.each {|match|
      html_select =
                "<select name='result_#{match.rowid}'>\n" +
                "\t<option value='1'>Winner is #{match.firstTeam}</option>\n" +
                "\t<option value='0'>It's a tie</option>\n" +
                "\t<option value='2'>Winner is #{match.secondTeam}</option>\n" +
                "</select>"
                
      @results[match.rowid] = html_select
    }
  end
  
  erb :results
end

post '/results' do
  redirect '/login' if !logged_in?
  protected!
  
  @viewTitle = "Match results"
  @pool = Pool.find_closed
  
  params.each {|param|
    if param[0].start_with?('result')
      rowid = param[0].split('_')[1]
      match = Match.find(rowid)
      
      if match == nil
        @error = "Something weird happened. We couldn't find that match."
        return erb :results
      end
      
      match.result = param[1]
      match.save
    end
  }
  
  @pool.open = Pool::CONCLUDED
  @pool.save
  
  redirect '/scores'
end

get '/pick' do
  redirect '/login' if !logged_in?
  
  @viewTitle = "Make your pick"
  @pool = Pool.find_open
  @picks = {}
  
  if !@pool
    return erb :pick
  end
  
  user = session[:login]
  user_picks = user.picks
  
  @pool.matches.each {|match|
    html_select =
                "<select name='result_#{match.rowid}'>\n" +
                "\t<option value='1' #{'selected' if user_picks.select{ |pick| pick.match.rowid.to_s == match.rowid.to_s && pick.choice.to_s == '1'}.count > 0}>Winner is #{match.firstTeam}</option>\n" +
                "\t<option value='0' #{'selected' if user_picks.select{ |pick| pick.match.rowid.to_s == match.rowid.to_s && pick.choice.to_s == '0'}.count > 0}>It's a tie</option>\n" +
                "\t<option value='2' #{'selected' if user_picks.select{ |pick| pick.match.rowid.to_s == match.rowid.to_s && pick.choice.to_s == '2'}.count > 0}>Winner is #{match.secondTeam}</option>\n" +
                "</select>"
                
    @picks[match.rowid] = html_select            
  }
  
  erb :pick
end

post '/pick' do
  redirect '/login' if !logged_in?
  
  @viewTitle = "Make your pick"
  @pool = Pool.find_open
  @picks = {}
  
  if !@pool
    return erb :pick
  end
  
  user = session[:login]
  
  params.each {|param|
    if param[0].start_with?('result')
      rowid = param[0].split('_')[1]
      match = Match.find(rowid)
      
      if match == nil
        @error = "Something weird happened. We couldn't find that match."
        return erb :pick
      end
        
      pick = user.pick_by_match(match.rowid)
      if pick == nil
        pick = Pick.new(user, match, Match::NO_RESULTS)
      end
        
      pick.choice = param[1]
      pick.save
    end
    
    @status = 'We have updated your picks.'
  }
  
  user_picks = user.picks
  @pool.matches.each {|match|
    html_select =
                "<select name='result_#{match.rowid}'>\n" +
                "\t<option value='1' #{'selected' if user_picks.select{ |pick| pick.match.rowid.to_s == match.rowid.to_s && pick.choice.to_s == '1'}.count > 0}>Winner is #{match.firstTeam}</option>\n" +
                "\t<option value='0' #{'selected' if user_picks.select{ |pick| pick.match.rowid.to_s == match.rowid.to_s && pick.choice.to_s == '0'}.count > 0}>It's a tie</option>\n" +
                "\t<option value='2' #{'selected' if user_picks.select{ |pick| pick.match.rowid.to_s == match.rowid.to_s && pick.choice.to_s == '2'}.count > 0}>Winner is #{match.secondTeam}</option>\n" +
                "</select>"
                
    @picks[match.rowid] = html_select            
  }
  
  erb :pick
end

get '/scores' do
  @viewTitle = "Scores"
  @scores = []
  
  pools = Pool.find_all
  titles = ['User']
  pools.each {|pool|
    titles << "P#{pool.rowid}"
  }
  titles << "Total"
  @scores << titles
  
  score_data = []
  
  Account.find_all.each {|account|
    pool_score = Hash.new(0)
    account.picks.each {|pick|
      if pick.choice.to_s == pick.match.result.to_s
        pool_score[pick.match.pool.rowid] += 1
      end
    }
    
    user_scores = [account.login]
    pools.each {|pool|
      user_scores << pool_score[pool.rowid]
    }
    
    user_scores << user_scores.drop(1).reduce(0, :+)
    
    score_data << user_scores
  }
  
  @scores += score_data.sort{ |x, y| x.last <=> y.last }.reverse
  
  erb :scores
end

error 401 do
  @viewTitle = 'Unauthorized'
  erb :unauthorized
end

not_found do
  status 404
  @viewTitle = 'Not Found'
  erb :notfound
end

error do
  status 500
  @viewTitle = 'Internal Server Error'
  erb :error
end