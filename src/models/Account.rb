# Final Project: Soccer Pool
# Date: 30-Nov-2015
# Authors: A01164759 Mauricio Cunille
#          A01169513 Daniela Ortiz

require '../server_config'
require 'sqlite3'

# The Sqlite3 database object.
DATA_BASE = SQLite3::Database.new(ServerConfig.instance.db_name)

# The +Account+ class is an active record representing
# a row in the +accounts+ table.
class Account
  
  # The table row ID.
  attr_reader :rowid

  # The account's login.
  attr_accessor :login

  # The account's password.
  attr_accessor :password
  
  # The account's role.
  attr_accessor :role
  
  # The account's score.
  attr_accessor :score
  
  @@cache = {}
  
  # Create the +accounts+ table, deleting the previous
  # one if it exists.
  def self.create_table
    DATA_BASE.execute("create table if not exists #{ TABLE_NAME } (" +
      'login text, password text, role text, score integer)')
  end
  
  # Creates a new +Account+ instance.
  #
  # Parameters::
  #
  #  login:: The account's name.
  #  password:: The account's password.
  #  role:: The account's role.
  #  score:: The account's score.
  def initialize(login, password, role, score = 0)
    @rowid = nil
    @login = login
    @password = password
    @role = role
    @score = score
  end
  
  # Saves the state of this account instance.
  def save
    if @rowid
      DATA_BASE.execute("update #{ TABLE_NAME } set " +
                        'login=?, password=?, role=?, score=? ' +
                        'where rowid=?', [login, password, role, score, @rowid])
    else
      DATA_BASE.execute("insert into #{ TABLE_NAME } " +
                        'values (?, ?, ?, ?)', [login, password, role, score])
      @rowid = DATA_BASE.get_first_row("select max(rowid) from #{ TABLE_NAME }")[0]
      @@cache[rowid] = self
    end
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
    return @@cache[rowid] if @@cache.has_key?(rowid)

    row = DATA_BASE.get_first_row("select * from #{ TABLE_NAME } " +
                                  'where rowid=?', [rowid])

    if row
      account = Account.new(row[0], row[1], row[2], row[3])
      account.instance_variable_set(:@rowid, rowid)
      @@cache[rowid] = account
      account
    else
      nil
    end
  end
  
  # Get all the accounts contained in the database.
  #
  # Returns:: An array with all the accounts
  #           currently stored in the +accounts+
  #           table.
  def self.find_all
    result = []
    DATA_BASE.execute(
      "select rowid, * from #{ TABLE_NAME }") do |row|
      rowid = row[0]
      if !@@cache.has_key?(rowid)
        account = Account.new(row[1], row[2], row[3], row[4])
        account.instance_variable_set(:@rowid, rowid)
        @@cache[rowid] = account
      end
      result << @@cache[rowid]
    end
    result
  end
  
  # Get a string containing the representation for this
  # account object.
  def to_s
    inspect
  end
  
  private 
  
  # The table name.
  TABLE_NAME = 'accounts'
  
  # Get a string containing the representation for this
  # account object.
  def inspect
    "Account_#{ rowid }(login=#{ login }, password=#{ password }, role=#{ role }, score=#{ score })"
  end
end