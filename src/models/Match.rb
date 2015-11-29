# Final Project: Soccer Pool
# Date: 30-Nov-2015
# Authors: A01164759 Mauricio Cunille
#          A01169513 Daniela Ortiz

require_relative 'ActiveRecordModel'
require_relative 'Pool'

# The +Match+ class is an active record representing
# a row in the +matches+ table.
class Match < ActiveRecordModel
  
  # The table name.
  @table_name = "matches"

  # The match has no results.
  NO_RESULTS = -1
  
  # The match was a tie.
  TIE = 0
  
  # The first team won!
  WINNER_TEAM_A = 1
  
  # The second team won!
  WINNER_TEAM_B = 2

  # The match's first team.
  attr_accessor({:firstTeam => "text"})

  # The match's second team.
  attr_accessor({:secondTeam => "text"})
  
  # The match's result.
  attr_accessor({:result => "text"})
  
  # The match's pool.
  attr_accessor({:pool => "foreign_key@#{Pool.table_name}"})
  
  # Creates a new +Match+ instance.
  #
  # Parameters::
  #
  #  firstTeam:: The first team's name.
  #  secondTeam:: The second team's name.
  #  results:: The match's result.
  def initialize(firstTeam, secondTeam, result = NO_RESULTS, pool = nil)
    @firstTeam = firstTeam
    @secondTeam = secondTeam
    @result = result
    @pool = pool
  end
  
  # Find a specific match contained in the database.
  #
  # Parameter::
  #
  #   rowid:: The row ID of the match to find in the
  #           database.
  #
  # Returns:: An instance of the +Match+ class with
  #           the given row ID, or +nil+ if not found.
  def self.find(rowid)
    super(rowid) {|row|
      pool = Pool.find(row[3])
      Match.new(row[0], row[1], row[2], pool)
    }
  end
  
  # Get all the accounts contained in the database.
  #
  # Returns:: An array with all the accounts
  #           currently stored in the +accounts+
  #           table.
  def self.find_all
    super{|row|
        pool = Pool.find(row[4])
        Match.new(row[1], row[2], row[3], pool)
      }
  end
  
end