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
user.picks.each {|e| puts e}