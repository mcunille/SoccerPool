# Final Project: Soccer Pool
# Date: 30-Nov-2015
# Authors: A01164759 Mauricio Cunille
#          A01169513 Daniela Ortiz

require 'sqlite3'
require_relative '../server_config'
require_relative 'ClassLevelInheritableAttributes'

# The Sqlite3 database object.
DATA_BASE = SQLite3::Database.new(ServerConfig.instance.db_name)

# The +ActiveRecordModel+ class is an active record template
# representing a row in the +child+ table.
class ActiveRecordModel
  include ClassLevelInheritableAttributes
  
  inheritable_attributes :table_name, :attributes, :cache
  
  # The table name
  @table_name = nil
  
  # The table attributes
  @attributes = nil
  
  @cache = {}
  
  # The table row ID.
  attr_reader :rowid
  
  def self.attr_accessor(dictionary)
    raise 'Invalid attribute definition for Active Record' if !dictionary.is_a?(Hash)
    @attributes ||= {}
    @attributes.merge!(dictionary)
    vars = dictionary.map{ |v| v[0] }
    super(*vars)
  end
  
  # Create the table
  # only if it doesn't exist.
  def self.create_table
    raise 'Invalid attributes' if @attributes == nil
    raise 'Invalid table name' if @table_name == nil
    
    constraints = ""
    query = "create table if not exists #{ @table_name } (" +
                      @attributes.map{|a|
                        if a[1].start_with?('foreign_key')
                          constraints += ", foreign key(#{a[0]}_id) references #{a[1].split('@')[1]}(rowid)"
                          "#{a[0]}_id integer"
                        else
                          "#{a[0]} #{a[1]}"
                        end
                        }.join(', ') +
                      " #{constraints})"
    
    DATA_BASE.execute(query)
  end
  
  # Saves the state of this instance.
  def save
    values = []
    self.class.attributes.each do |attribute|
      ivar_value = self.instance_variable_get "@#{attribute[0]}"
      
      if attribute[1].start_with?('foreign_key')
        ivar_value = ivar_value.nil? ? nil : ivar_value.rowid
      end
      
      values << ivar_value
    end
    
    if @rowid
      values << @rowid
      query = "update #{ self.class.table_name } set " +
                        self.class.attributes.map{|v|
                          if v[1].start_with?('foreign_key')
                            "#{v[0]}_id=?"
                          else  
                            "#{v[0]}=?"
                          end
                          }.join(', ') +
                        ' where rowid=?'
                        
      DATA_BASE.execute(query, values)
    else
      query = "insert into #{ self.class.table_name } values (" +
                        self.class.attributes.map{|v| "?"}.join(', ') +
                        ')'
      
      DATA_BASE.execute(query, values)
      @rowid = DATA_BASE.get_first_row("select max(rowid) from #{ self.class.table_name }")[0]
      self.class.cache[rowid] = self
    end
  end
  
  # Find a specific instance contained in the database.
  #
  # Must pass a block that creates the +child+ object.
  #
  # Parameter::
  #
  #   rowid:: The row ID of the instance to find in the
  #           database.
  #
  # Returns:: An array of the row with
  #           the given row ID, or +nil+ if not found.
  def self.find(rowid)
    return @cache[rowid] if @cache.has_key?(rowid)
    query = "select * from #{ @table_name } where rowid=?"
    row = DATA_BASE.get_first_row(query, [rowid])
    
    if row
      object = yield row
      object.instance_variable_set(:@rowid, rowid)
      @cache[rowid] = object
      puts @cache
      object
    else
      nil
    end
  end
  
  # Get all the instances contained in the database.
  #
  # Must pass a block that creates the +child+ object.
  #
  # Returns:: An array with all the instances
  #           currently stored in the +child+
  #           table.
  def self.find_all
    result = []
    
    query = "select rowid, * from #{ @table_name }"
    
    DATA_BASE.execute(query) do |row|
      rowid = row[0]
      if !@cache.has_key?(rowid)
        object = yield row
        object.instance_variable_set(:@rowid, rowid)
        @cache[rowid] = object
      end
      result << @cache[rowid]
    end
    result
  end
  
  # Get a string containing the representation for this
  # object.
  def to_s
    inspect
  end
  
  private 

  # Get a string containing the representation for this
  # object.
  def inspect
    "#{self.class.name}_#{ rowid }(" +
    self.class.attributes.map{ |var|
        value = self.instance_variable_get "@#{var[0]}"
        "#{var[0]}=#{value}"
        }.join(', ') +
    ")"
  end
  
end