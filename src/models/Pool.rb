# Final Project: Soccer Pool
# Date: 30-Nov-2015
# Authors: A01164759 Mauricio Cunille
#          A01169513 Daniela Ortiz

require_relative 'ActiveRecordModel'

# The +Pool+ class is an active record representing
# a row in the +pools+ table.
class Pool < ActiveRecordModel
  
  # The pool is open.
  OPEN = 1
  
  # The pool is closed.
  CLOSED = 0
  
  # The pool has concluded.
  CONCLUDED = 2
  
  # The table name.
  @table_name = 'pools'
  
  # Whether the pool is open.
  attr_accessor({:open => "integer"})
  
  @cache = {}
  
  # Creates a new +Pool+ instance.
  #
  # Parameters::
  #
  #  open:: Whether the pool is open.
  def initialize(open = CLOSED)
    @rowid = nil
    @open = open
  end
  
  # Find a specific pool contained in the database.
  #
  # Parameter::
  #
  #   rowid:: The row ID of the pool to find in the
  #           database.
  #
  # Returns:: An instance of the +Pool+ class with
  #           the given row ID, or +nil+ if not found.
  def self.find(rowid)
    super(rowid) { |row|
      Pool.new(row[0])}
  end
  
  # Get all the pools contained in the database.
  #
  # Returns:: An array with all the pools
  #           currently stored in the +pools+
  #           table.
  def self.find_all
    super { |row|
        Pool.new(row[1])}
  end
  
  # Find a specific pool contained in the database.
  #
  # RETURNS:: An instance of the +Pool+ class that
  #           is open, or +nil+ if not found.
  def self.find_open
    query = "select rowid, * from #{Pool.table_name} " +
            'where open=?'
            
    row = DATA_BASE.get_first_row(query, [OPEN])
    
    if row
      pool = Pool.new(row[1])
      pool.instance_variable_set(:@rowid, row[0])
      pool
    end
  end
  
  # Find a specific pool contained in the database.
  #
  # RETURNS:: An instance of the +Pool+ class that
  #           is closed but not concluded, or +nil+ if not found.
  def self.find_closed
    query = "select rowid, * from #{Pool.table_name} " +
            'where open=?'
            
    row = DATA_BASE.get_first_row(query, [CLOSED])
    
    if row
      pool = Pool.new(row[1])
      pool.instance_variable_set(:@rowid, row[0])
      pool
    end
  end
  
  # Returns an array of all the matches that belong to
  # this pool.
  def matches
    result = []
    query = "select #{Match.table_name}.rowid from #{Match.table_name}, #{Pool.table_name} " +
            "where #{Pool.table_name}.rowid=pool_id and pool_id=?"
            
    DATA_BASE.execute(query, [rowid]) do |row|
      result << Match.find(row[0])
    end
    
    result
  end
  
end