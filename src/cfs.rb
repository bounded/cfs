module CFS

  class Database
    def add node
      # same level => not the same literal
    end
    def merge db
      db.each {|x|
        add x
      }
    end
  end

  class Node
    attr_reader :children
    attr_reader :connections

    def initialize literal
      @literal = literal
      @children = []
      @connections = []
    end      

    def add_child obj
      raise ArgumentError if @children.include? obj
      @children << obj 
    end

    def add_connection obj
      raise ArgumentError if @connections.include? obj
      @connections << obj 
    end
  end

  DEBUG = false

  def self.debug str
    puts str if DEBUG
  end

end
