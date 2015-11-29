# Final Project: Soccer Pool
# Date: 30-Nov-2015
# Authors: A01164759 Mauricio Cunille
#          A01169513 Daniela Ortiz

require 'singleton'
# The +ServerConfig+ class is a singleton class
# representing the server configuration.
class ServerConfig
  include Singleton
  
  # The database name.
  attr_reader :db_name
  
  def initialize
    @db_name = 'soccer.db'
  end
  
end