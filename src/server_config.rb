# Final Project: Soccer Pool
# Date: 30-Nov-2015
# Authors: A01164759 Mauricio Cunille
#          A01169513 Daniela Ortiz

require 'singleton'

class ServerConfig
  include Singleton
  
  attr_reader :db_name
  
  def initialize()
    @db_name = 'soccer.db'
  end
end