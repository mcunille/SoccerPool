# Final Project: Soccer Pool
# Date: 30-Nov-2015
# Authors: A01164759 Mauricio Cunille
#          A01169513 Daniela Ortiz

require_relative 'ActiveRecordModel'

# The +Pick+ class is an active record representing
# a row in the +picks+ table.
class Pick < ActiveRecordModel
  
  # The table name.
  @table_name = 'picks'

  # The pick's user.
  attr_accessor({:account => "foreign_key@#{Account.table_name}"})

  # The pick's match.
  attr_accessor({:match => "foreign_key@#{Match.table_name}"})
  
  # The pick's choice.
  attr_accessor({:choice => "integer"})
  
  # Creates a new +Pick+ instance.
  #
  # Parameters::
  #
  #  account:: The pick's user.
  #  match:: The pick's match.
  #  choice:: The pick's choice.
  def initialize(account, match, choice)
    @rowid = nil
    @account = account
    @match = match
    @choice = choice
  end
  
  # Find a specific pick contained in the database.
  #
  # Parameter::
  #
  #   rowid:: The row ID of the pick to find in the
  #           database.
  #
  # Returns:: An instance of the +Pick+ class with
  #           the given row ID, or +nil+ if not found.
  def self.find(rowid)
    super(rowid) {|row|
      account = Account.Find(row[0])
      match = Match.Find(row[1])
      Pick.new(account, match, row[2])
    }
  end
  
  # Get all the picks contained in the database.
  #
  # Returns:: An array with all the picks
  #           currently stored in the +picks+
  #           table.
  def self.find_all
    super{|row|
        account = Account.Find(row[1])
        match = Match.Find(row[2])
        Pick.new(account, match, row[3])
      }
  end
end