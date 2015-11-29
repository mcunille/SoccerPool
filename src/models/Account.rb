# Final Project: Soccer Pool
# Date: 30-Nov-2015
# Authors: A01164759 Mauricio Cunille
#          A01169513 Daniela Ortiz

require_relative 'ActiveRecordModel'

# The +Account+ class is an active record representing
# a row in the +accounts+ table.
class Account < ActiveRecordModel

  # The table name.
  @table_name = 'accounts'

  # The account's login.
  attr_accessor({:login => "text unique"})

  # The account's password.
  attr_accessor({:password => "text"})
  
  # The account's role.
  attr_accessor({:role => "text"})
  
  @cache = {}
  
  # Creates a new +Account+ instance.
  #
  # Parameters::
  #
  #  login:: The account's name.
  #  password:: The account's password.
  #  role:: The account's role.
  def initialize(login, password, role)
    @rowid = nil
    @login = login
    @password = password
    @role = role
  end
  
  # Find a specific account contained in the database.
  #
  # Parameter::
  #
  #   rowid:: The row ID of the account to find in the
  #           database.
  #
  # Returns:: An instance of the +Account+ class with
  #           the given row ID, or +nil+ if not found.
  def self.find(rowid)
    super(rowid) {|row|
      Account.new(row[0], row[1], row[2])
    }
  end
  
  # Get all the accounts contained in the database.
  #
  # Returns:: An array with all the accounts
  #           currently stored in the +accounts+
  #           table.
  def self.find_all
    super{|row|
        Account.new(row[1], row[2], row[3])
      }
  end
  
  # Find a specific account contained in the database.
  #
  # Parameter::
  #
  #   login:: The login of the account to find in the
  #           database.
  #
  # Returns:: An instance of the +Account+ class with
  #           the given login, or +nil+ if not found.
  def self.find_by_login(login)
    query = "select rowid, * from #{Account.table_name} " +
            "where login=?"
            
    row = DATA_BASE.get_first_row(query, [login])
    
    if row
      account = Account.new(row[1], row[2], row[3])
      account.instance_variable_set(:@rowid, row[0])
      account
    end
  end
  
  # Returns an array of all the picks that belong to
  # this account.
  def picks
    result = []
    query = "select #{Pick.table_name}.rowid from #{Pick.table_name}, #{Account.table_name} " +
            "where #{Account.table_name}.rowid=account_id and account_id=?"
            
    DATA_BASE.execute(query, [rowid]) do |row|
      pick = Pick.find(row[0])
      result << pick
    end
    
    result
  end
end
