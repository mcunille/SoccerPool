require_relative 'models/Account'
require_relative 'models/Match'
require_relative 'models/Pick'
require_relative 'models/Pool'

def create_database
  Account.create_table
  Pool.create_table
  Match.create_table
  Pick.create_table
end 

create_database

begin
  user = Account.new("mcunille", "123456", "admin")
  user.save
  puts("saved: #{user}")
rescue
 #ignore
end

begin
  user = Account.new("dortiz", "123456", "user")
  user.save
  puts("saved: #{user}")
rescue
  # ignore
end

admin = Account.find_by_login("mcunille")
puts admin

user = Account.find_by_login("dortiz")
puts user

pool = Pool.new(Pool::OPEN)
pool.save
puts pool

match1 = Match.new("A", "B", Match::NO_RESULTS, pool)
match1.save
puts match1

match2 = Match.new("C", "D", Match::NO_RESULTS, pool)
match2.save
puts match2

Pick.new(user, match1, Match::TIE).save
Pick.new(user, match2, Match::WINNER_TEAM_A).save

user.picks.each {|e| puts e}
